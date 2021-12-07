//
//  PlacesAPI.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import Combine
import Foundation

fileprivate let apiKey = "AIzaSyDue_S6t9ybh_NqaeOJDkr1KC9a2ycUYuE"

enum Endpoint {
    static let baseURL = "https://maps.googleapis.com/maps/api/place/"
    
    case nearbyPlaces(String, String)
    case search(String)
    
    var stringValue: String {
        switch self {
        case .nearbyPlaces(let latitude, let longitude): return Endpoint.baseURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=50000&keyword=food&rankby=prominence&key=\(apiKey)"
        case .search(let query): return "textsearch/json?query=\(query)&key=\(apiKey)"
        }
    }
    
    var url: URL {
        return URL(string: self.stringValue)!
    }
}

class PlacesAPI {
    
    func fetchNearbyRestaurants(latitude: String, longitude: String) -> AnyPublisher<[Restaurant], Error> {
        let url = Endpoint.nearbyPlaces(latitude, longitude).url
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Restaurants.self, decoder: JSONDecoder())
            .map({ restaurants in
                restaurants.results
            })
            .eraseToAnyPublisher()
    }
}
