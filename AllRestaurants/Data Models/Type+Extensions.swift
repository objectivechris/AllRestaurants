//
//  Type+Extensions.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/6/21.
//

import Foundation
import UIKit
import SwiftUI

extension Int {
    var abbreviated: String {
        if self >= 1000 && self < 10000 {
            return String(format: "%.1fK", Double(self/100)/10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000 && self < 1000000 {
            return "\(self/1000)K"
        }

        if self >= 1000000 && self < 10000000 {
            return String(format: "%.1fM", Double(self/100000)/10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000000 {
            return "\(self/1000000)M"
        }

        return String(self)
    }
}

extension UIImageView {
    // Download and cache place icons for later use
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) async throws {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = placeholder
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw GMError.requestFailed }
            let image = UIImage(data: data)
            let cachedData = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedData, for: request)
            self.image = image
        }
    }
}

extension UIColor {
    static var allTrailsGreen = UIColor(named: "allGreen")!
}

extension Color {
    static var allTrailsGreen = Color(UIColor.allTrailsGreen)
}
