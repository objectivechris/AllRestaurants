//
//  RestaurantAnnotation.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/8/21.
//

import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var restaurant: Restaurant
    var title: String?
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.coordinate = restaurant.coordinate
    }
}
