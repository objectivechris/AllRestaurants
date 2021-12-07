//
//  RestaurantViewModel.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/5/21.
//

import CoreLocation
import Foundation
import CoreGraphics

class RestaurantViewModel {
    
    let name: String
    let priceLevel: String
    let starRating: Double
    let reviewCount: Int
//    let address: String
    let imageURL: URL
//    let distance: String
    
    private let restaurant: Restaurant
    
    lazy var distance: String = {
        return String(format: "%.1f", distanceInMiles(from: restaurant.location)) + "mi"
    }()
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        name = restaurant.name
        priceLevel = restaurant.priceLevel == 0 ? "$" : String(repeating: "$", count: restaurant.priceLevel)
        starRating = restaurant.rating
        reviewCount = restaurant.userRatingsTotal
        imageURL = URL(string: "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png")!
    }
    
    func distanceInMiles(from coordinates: Restaurant.Coordinates) -> Double {
        guard let currentLocation = CLLocationManager().location else { return 0.0 }
        let restaurantLocation = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lng)
        return distance(from: currentLocation.coordinate, coordinate2: restaurantLocation)
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
