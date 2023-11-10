//
//  RestaurantInfoView.swift
//  AllRestaurants
//
//  Created by Chris Rene on 11/6/23.
//

import MapKit
import SwiftUI

struct RestaurantInfoView: View {
    
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedRestaurant: Restaurant
    var route: MKRoute?
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    if let travelTime {
                        Button(action: openRestaurantInMaps) {
                            Label(travelTime, systemImage: "car.fill")
                                .padding(.horizontal, 8)
                        }
                        .frame(height: 20)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding (10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedRestaurant) {
                getLookAroundScene()
            }
    }
    
    private func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedRestaurant.coordinate)
            lookAroundScene = try? await request.scene
        }
    }
    
    private func openRestaurantInMaps() {
        let mapItem = MKMapItem(placemark: .init(coordinate: selectedRestaurant.coordinate))
        mapItem.name = selectedRestaurant.name
        mapItem.openInMaps()
    }
}

#Preview {
    RestaurantInfoView(selectedRestaurant: Restaurant.example().first!, route: .init())
}
