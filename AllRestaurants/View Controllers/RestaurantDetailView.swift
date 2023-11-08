//
//  RestaurantDetailView.swift
//  AllRestaurants
//
//  Created by Chris Rene on 11/6/23.
//

import MapKit
import SwiftUI

struct RestaurantDetailView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var address: String?
    
    var viewModel: RestaurantCellViewModel
    var route: MKRoute?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                RestaurantInfoView(selectedRestaurant: viewModel.restaurant, route: route)
                    .frame(height: 128)
                    .clipShape(RoundedRectangle (cornerRadius: 10))
                    .padding([.top, .horizontal])
                                
                HStack {
                    VStack {
                        Text("HOURS")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(viewModel.isOpen ? "Open" : "Closed")
                            .foregroundStyle(viewModel.isOpen ? .green : .red)
                    }
                    Spacer()
                    VStack {
                        Text("RATINGS")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(viewModel.reviewCount.abbreviated)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    VStack {
                        Text("COST")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.priceLevel)")
                    }
                    
                    Spacer()
                    VStack {
                        Text("DISTANCE")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(viewModel.distance)
                    }
                }
                .padding(.horizontal, 20)
            }
            .bold()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Spacer()
                        Text(viewModel.name)
                            .font(.headline)
                        Text(address ?? "N/A")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: viewModel.restaurant) {
            getLookAroundScene()
        }
        .onAppear {
            populateAddress()
        }
    }
    
    private func populateAddress() {
        Task {
            do {
                if let placemark = try await CLGeocoder().reverseGeocodeLocation(.init(latitude: viewModel.restaurant.coordinate.latitude, longitude: viewModel.restaurant.coordinate.longitude)).first {
                    address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? "")"
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let mapItem = MKMapItem(placemark: .init(coordinate: viewModel.restaurant.coordinate))
            let request = MKLookAroundSceneRequest(mapItem: mapItem)
            lookAroundScene = try? await request.scene
        }
    }
}

#Preview {
    RestaurantDetailView(viewModel: RestaurantCellViewModel(restaurant: Restaurant.example().first!, location: .init(latitude: 33.8995, longitude: -84.4617)))
}
