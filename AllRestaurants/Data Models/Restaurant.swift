//
//  Restaurant.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/4/21.
//

import Foundation
import CoreLocation
import UIKit

struct Restaurants: Decodable {
    let results: [Restaurant]
}

struct Restaurant: Decodable, Hashable, Identifiable {
    let id = UUID()
    let name: String
    let priceLevel: Int
    let rating: Double
    let userRatingsTotal: Int
    let location: Coordinates
    let isOpen: Bool
    let photoId: String

    enum CodingKeys: String, CodingKey {
        case name, rating
        case priceLevel = "price_level"
        case userRatingsTotal = "user_ratings_total"
        case status = "business_status"
        case geometry = "geometry"
        case photos = "photos"
        case isOpen = "opening_hours"
    }
    
    struct OpeningHours: Decodable, Hashable {
        let open_now: Bool
    }
    
    struct Photo: Decodable, Hashable {
        let photo_reference: String
    }
    
    struct Geometry: Decodable, Hashable {
        let location: Coordinates
    }
    
    struct Coordinates: Decodable, Hashable {
        let lat: Double
        let lng: Double
    }
}

extension Restaurant {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel) ?? 0
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal) ?? 0
        self.location = try container.decodeIfPresent(Geometry.self, forKey: .geometry)?.location ?? Coordinates(lat: 0, lng: 0)
        self.photoId = try container.decodeIfPresent([Photo].self, forKey: .photos)?.first?.photo_reference ?? ""
        self.isOpen = try container.decodeIfPresent(OpeningHours.self, forKey: .isOpen)?.open_now ?? false
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
    }
    
    static func example() -> [Restaurant] {
        return [Restaurant(name: "Maggiano's Little Italy",priceLevel: 2,
                           rating: 4.3,
                           userRatingsTotal: 3571,
                           location: Restaurant.Coordinates(lat: 33.8807, lng: -84.4677), 
                           isOpen: true,
                           photoId: ""), Restaurant(name: "Ray's on the River",
                                                    priceLevel: 3,
                                                    rating: 4.7,
                                                    userRatingsTotal: 8997,
                                                    location: Restaurant.Coordinates(lat: 33.9004, lng: -84.4408), 
                                                    isOpen: false,
                                                    photoId: ""), Restaurant(name: "Bowlero Marietta",
                                                                             priceLevel: 0,
                                                                             rating: 4.3,
                                                                             userRatingsTotal: 3,
                                                                             location: Restaurant.Coordinates(lat: 33.9239, lng: -84.4738), 
                                                                             isOpen: true,
                                                                             photoId: "")]
    }
}
