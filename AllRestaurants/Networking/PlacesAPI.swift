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
    case search(String, String, String)
    case photo(String)
    
    var stringValue: String {
        switch self {
        case .nearbyPlaces(let latitude, let longitude):
            return Endpoint.baseURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=50000&type=restaurant&key=\(apiKey)"
        case .search(let query, let latitude, let longitude):
            let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return Endpoint.baseURL + "textsearch/json?location=\(latitude),\(longitude)&radius=50000&query=\(query)&type=restaurant&key=\(apiKey)"
        case .photo(let photoId):
            return Endpoint.baseURL + "photo?maxwidth=400&photo_reference=\(photoId)&key=\(apiKey)"
        }
    }
    
    var url: URL {
        return URL(string: self.stringValue)!
    }
}

class PlacesAPI {
    
    // Publishers using Combine
    func fetchNearbyRestaurants(latitude: String, longitude: String) -> AnyPublisher<[Restaurant], Error> {
        let url = Endpoint.nearbyPlaces(latitude, longitude).url
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Restaurants.self, decoder: JSONDecoder())
            .map { restaurants in
                restaurants.results
            }
            .eraseToAnyPublisher()
    }
    
    func search(withText text: String, latitude: String, longitude: String) -> AnyPublisher<[Restaurant], Error> {
        let url = Endpoint.search(text, latitude, longitude).url
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Restaurants.self, decoder: JSONDecoder())
            .map { restaurants in
                restaurants.results
            }
            .eraseToAnyPublisher()
    }
}
