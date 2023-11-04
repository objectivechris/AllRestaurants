//
//  GMClient.swift
//  AllRestaurants
//
//  Created by Chris Rene on 10/29/23.
//

import Foundation

class GMClient {
    
    private let session: URLSession
    
    private init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getNearbyRestaurants(fromLocation location: Location) async throws -> [Restaurant] {
        return try await request(url: GMEndpoint.nearbyPlaces(location.latitude, location.longitude).url, responseType: Restaurants.self).results
    }
    
    func searchForRestaurants(fromLocation location: Location, withText text: String) async throws -> [Restaurant] {
        return try await request(url: GMEndpoint.search(text, location.latitude, location.longitude).url, responseType: Restaurants.self).results
    }
}

private extension GMClient {
    // Decodes types that only conform to Decodable
    func request<ResponseType: Decodable>(url: URL?, responseType: ResponseType.Type) async throws -> ResponseType {
        guard let url else { throw GMError.invalidURL }
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw GMError.invalidServerResponse }
            let decoder = JSONDecoder()
            return try decoder.decode(ResponseType.self, from: data)
        } catch {
            throw GMError.parsingFailure
        }
    }
}

