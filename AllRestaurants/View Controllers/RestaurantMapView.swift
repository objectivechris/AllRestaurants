//
//  RestaurantMapView.swift
//  AllRestaurants
//
//  Created by Chris Rene on 11/1/23.
//

import MapKit
import SwiftUI

struct RestaurantMapView: View {
    
    @StateObject var viewModel: RestaurantViewModel
    @State private var selectedRestaurant: Restaurant?
    @State private var locationManager = CLLocationManager()
    @State private var position: MapCameraPosition = .automatic
    @State private var route: MKRoute?
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $selectedRestaurant) {
                ForEach(viewModel.restaurants, id: \.self) { restaurant in
                    Marker(restaurant.name, systemImage: "fork.knife", coordinate: restaurant.coordinate)
                        .tint(Color.allTrailsGreen)
                }
                
                UserAnnotation()
                
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
        .onChange(of: selectedRestaurant) {
            getDirections()
        }
        .onChange(of: viewModel.restaurants) {
            setRegionThatFitsAnnotations()
        }
        .sheet(item: $selectedRestaurant) { rest in
            RestaurantDetailView(viewModel: .init(restaurant: rest), route: route)
                .presentationDetents([.height(250)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(250)))
        }
        .tint(Color.blue)
        .ignoresSafeArea(edges: .bottom)
        .mapControls {
            MapUserLocationButton()
                .buttonBorderShape(.circle)
            MapCompass()
            MapScaleView()
        }
    }
    
    private func getDirections() {
        route = nil
        guard let selectedRestaurant else { return }
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = MKMapItem(placemark: .init(coordinate: selectedRestaurant.coordinate))
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
    
    private func setRegionThatFitsAnnotations() {
        let coordinates = viewModel.restaurants.map(\.location)
        if let maxLat = coordinates.map(\.lat).max(),
           let minLat = coordinates.map(\.lat).min(),
           let maxLon = coordinates.map(\.lng).max(),
           let minLon = coordinates.map(\.lng).min() {
            
            let span = MKCoordinateSpan(
                latitudeDelta: maxLat - minLat,
                longitudeDelta: maxLon - minLon
            )
            
            let center = CLLocationCoordinate2D(
                latitude: (maxLat + minLat) / 2,
                longitude: (maxLon + minLon) / 2
            )
            
            position = .region(.init(center: center, span: span))
            selectedRestaurant = nil
        }
    }
}

#Preview {
    RestaurantMapView(viewModel: RestaurantViewModel.example())
}
