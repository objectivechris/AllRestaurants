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
import MapKit

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

extension UIImage {
    static var activePin = UIImage(named: "active-pin")!
    static var staticPin = UIImage(named: "static-pin")!
    static var navBar = UIImage(named: "navbar-logo")!
}

extension UIImageView {
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = placeholder
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    if let data = data, let response = response, let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        self.image = image
                    }
                }
            }).resume()
        }
    }
}

extension UIColor {
    static var allTrailsGreen = UIColor(named: "AllGreen")!
}

extension Color {
    static var allTrailsGreen = Color(UIColor.allTrailsGreen)
}

extension MKAnnotationView {
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil) {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside = rect.contains(point)
        if(!isInside) {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        return isInside
    }
}

extension MKMapView {
    func zoomToFitAnnotations() {
        guard !annotations.isEmpty else { return }
        
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
        
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }

        let resd = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
        let span = MKCoordinateSpan(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3, longitudeDelta: fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3)
        
        var region = MKCoordinateRegion(center: resd, span: span)
        region = regionThatFits(region)

        setRegion(region, animated: true)
    }
    
    var mapWasDragged: Bool {
        if let gestureRecognizers = subviews.first?.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == .began || recognizer.state == .ended {
                    return true
                }
            }
        }
        return false
    }
}
