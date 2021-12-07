//
//  Type+Extensions.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/6/21.
//

import Foundation
import CoreGraphics
import UIKit
import SwiftUI

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

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

extension UIColor {
    static var allTrailsGreen = UIColor(named: "AllGreen")!
}

extension Color {
    static var allTrailsGreen = Color(UIColor.allTrailsGreen)
}
