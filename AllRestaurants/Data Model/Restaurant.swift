//
//  Restaurant.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/4/21.
//

import Foundation
import CoreLocation

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

    enum CodingKeys: String, CodingKey {
        case name, rating
        case priceLevel = "price_level"
        case userRatingsTotal = "user_ratings_total"
        case status = "business_status"
        case geometry = "geometry"
    }
    
    struct Geometry: Decodable, Hashable {
        let location: Coordinates
    }
    
    struct Coordinates: Decodable, Hashable {
        let lat: Double
        let lng: Double
        
        enum CoordinateKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "lng"
        }
    }
}

extension Restaurant {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Name Unknown"
        self.priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel) ?? 0
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal) ?? 0
        self.location = try container.decodeIfPresent(Geometry.self, forKey: .geometry)?.location ?? Coordinates(lat: 0, lng: 0)
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
    }
}
