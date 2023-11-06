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
    
    var body: some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: .all, selection: $selectedRestaurant) {
                ForEach(viewModel.restaurants, id: \.self) { restaurant in
                    Marker(restaurant.name, systemImage: "fork.knife", coordinate: restaurant.coordinate)
                        .tint(Color.allTrailsGreen)
                }
            }
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
        .mapControls {
            MapUserLocationButton()
                .buttonBorderShape(.circle)
            MapCompass()
            MapScaleView()
        }
        .onChange(of: selectedRestaurant) {
            print(selectedRestaurant)
        }
        .tint(Color.blue)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RestaurantMapView(viewModel: RestaurantViewModel.example())
}
