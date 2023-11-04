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
    let photoId: String
    let address: String

    enum CodingKeys: String, CodingKey {
        case name, rating
        case priceLevel = "price_level"
        case userRatingsTotal = "user_ratings_total"
        case status = "business_status"
        case geometry = "geometry"
        case photos = "photos"
        case address = "formatted_address"
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
        self.address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
    }
    
    static func example() -> [Restaurant] {
        return [Restaurant(name: "AA",
                                     priceLevel: 23,
                                     rating: 4,
                                     userRatingsTotal: 3,
                                     location: Restaurant.Coordinates(lat: 33.9196, lng: -84.4851),
                                     photoId: "",
                                     address: "")]        
    }
}
