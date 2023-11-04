//
//  GMEndpoint.swift
//  AllRestaurants
//
//  Created by Chris Rene on 10/29/23.
//

import Foundation

fileprivate let apiKey = "AIzaSyAHGsvS3dM5PgyW3OryWmqkjo0SKy0lRPU"

enum GMEndpoint {
    private var baseURL: String { "https://maps.googleapis.com/maps/api/place/" }
    
    case nearbyPlaces(Double, Double)
    case search(String, Double, Double)
    case photo(String)
    
    private var path: String {
        var endpoint: String
        
        switch self {
        case .nearbyPlaces(let lat, let lon):
            endpoint = "nearbysearch/json?location=\(lat),\(lon)&radius=50000&type=restaurant&key=\(apiKey)"
        case .search(let query, let lat, let lon):
            let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            endpoint = "textsearch/json?location=\(lat),\(lon)&radius=50000&query=\(query)&type=restaurant&key=\(apiKey)"
        case .photo(let photoId):
            endpoint = "photo?maxwidth=400&photo_reference=\(photoId)&key=\(apiKey)"
        }
        
        return baseURL + endpoint
    }
    
    var url: URL {
        guard let url = URL(string: path) else {
            preconditionFailure("The url is invalid")
        }
        return url
    }
}
