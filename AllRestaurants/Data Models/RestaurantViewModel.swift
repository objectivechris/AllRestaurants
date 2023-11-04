//
//  RestaurantViewModel.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/5/21.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

typealias Location = CLLocationCoordinate2D

@MainActor
public class RestaurantViewModel: ObservableObject {
    
    @Published var position: MapCameraPosition = .automatic
    @Published var restaurants: [Restaurant] = []
    @Published var error: GMError?
    @Published var isFetching: Bool = false // do I need this??
    
    private let client = GMClient()
    private let geocoder = CLGeocoder()
    
    func fetchNearbyRestaurants(fromLocation location: CLLocation?) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = try await client.getNearbyRestaurants(fromLocation: location.coordinate)
        if let restaurant = restaurants.first {
            self.updateMapPosition(location: CLLocation(latitude: restaurant.location.lat, longitude: restaurant.location.lng))
        }
    }
    
    func searchForRestaurants(fromLocation location: CLLocation?, withText text: String) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = try await client.searchForRestaurants(fromLocation: location.coordinate, withText: text)
        if let restaurant = restaurants.first {
            self.updateMapPosition(location: CLLocation(latitude: restaurant.location.lat, longitude: restaurant.location.lng))
        }
    }
    
    private func updateMapPosition(location: CLLocation) {
        position = .region(MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)))
    }
}
