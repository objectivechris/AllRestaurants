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
    
    @Published var restaurants: [Restaurant] = []
    @Published var error: GMError?
    @Published var isFetching: Bool = false
    
    private let client = GMClient()
    private let geocoder = CLGeocoder()
    
    func fetchNearbyRestaurants(fromLocation location: CLLocation?) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = []
        self.restaurants = try await client.getNearbyRestaurants(fromLocation: location.coordinate).sorted { (rest1, rest2) -> Bool in
            let location1 = CLLocation(latitude: rest1.location.lat, longitude: rest1.location.lng)
            let location2 = CLLocation(latitude: rest2.location.lat, longitude: rest2.location.lng)
            return location1.distance(from: location) < location2.distance(from: location)
        }
        isFetching = false
    }
    
    func searchForRestaurants(fromLocation location: CLLocation?, withText text: String) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = []
        self.restaurants = try await client.searchForRestaurants(fromLocation: location.coordinate, withText: text)
        isFetching = false
    }
}

extension RestaurantViewModel {
    static func example() -> RestaurantViewModel {
        let vm = RestaurantViewModel()
        vm.restaurants = Restaurant.example()
        return vm
    }
}
