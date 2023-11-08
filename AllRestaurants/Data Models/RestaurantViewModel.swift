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
    @Published var isFetching: Bool = false // do I need this??
    
    private let client = GMClient()
    private let geocoder = CLGeocoder()
    
    func fetchNearbyRestaurants(fromLocation location: CLLocation?) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = []
        self.restaurants = try await client.getNearbyRestaurants(fromLocation: location.coordinate)
    }
    
    func searchForRestaurants(fromLocation location: CLLocation?, withText text: String) async throws {
        guard let location else {
            error = GMError.locationNotFound
            return
        }
        
        isFetching = true
        self.restaurants = []
        self.restaurants = try await client.searchForRestaurants(fromLocation: location.coordinate, withText: text)
    }
}

extension RestaurantViewModel {
    static func example() -> RestaurantViewModel {
        let vm = RestaurantViewModel()
        vm.restaurants = Restaurant.example()
        return vm
    }
}
