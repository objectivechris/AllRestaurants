//
//  PlacesError.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import Foundation

enum PlacesError: Error {
    case requestFailed
    case parsingFailure
    case invalidURL
}
