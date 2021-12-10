//
//  RestaurantViewModel.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/5/21.
//

import Foundation
import CoreLocation
import CoreGraphics

class RestaurantViewModel {
    
    let name: String
    let priceLevel: String
    let starRating: Double
    let reviewCount: Int
    let photoId: String
    
    private let restaurant: Restaurant
    
    lazy var distance: String = {
        return String(format: "%.1f", distanceInMiles(from: restaurant.coordinate)) + "mi"
    }()
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        name = restaurant.name
        priceLevel = restaurant.priceLevel == 0 ? "$" : String(repeating: "$", count: restaurant.priceLevel)
        starRating = restaurant.rating
        reviewCount = restaurant.userRatingsTotal
        photoId = restaurant.photoId
    }
    
    func distanceInMiles(from coordinate: CLLocationCoordinate2D) -> Double {
        guard let currentLocation = CLLocationManager().location else { return 0.0 }
        return distance(from: currentLocation.coordinate, coordinate2: coordinate)
    }
    
    // Modified helper method from StackOverflow
    func distance(from coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> Double {
        let theta = coordinate1.longitude - coordinate2.longitude
        var distance = sin(coordinate1.latitude.degreesToRadians) * sin(coordinate2.latitude.degreesToRadians) + cos(coordinate1.latitude.degreesToRadians) * cos(coordinate2.latitude.degreesToRadians) * cos(theta.degreesToRadians)
        distance = acos(distance)
        distance = distance.radiansToDegrees
        distance = distance * 60 * 1.1515
        return distance
    }
}
