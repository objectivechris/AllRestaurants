//
//  GMError.swift
//  AllRestaurants
//
//  Created by Chris Rene on 10/29/23.
//

import Foundation

enum GMError: LocalizedError {
    case invalidServerResponse
    case requestFailed
    case parsingFailure
    case invalidURL
    case locationNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidServerResponse: "The server returned an invalid response."
        case .invalidURL: "URL string is malformed."
        case .requestFailed: "The network request has failed. Please try again."
        case .parsingFailure: "There was a parsing error."
        case .locationNotFound: "Invalid location. Please verify city is valid."
        }
    }
}
