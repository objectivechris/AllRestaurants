//
//  RestaurantViewModel.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/5/21.
//

import Foundation
import CoreLocation

class RestaurantCellViewModel {
    
    let name: String
    let priceLevel: String
    let starRating: Double
    let reviewCount: Int
    let photoId: String
    let isOpen: Bool
    
    let restaurant: Restaurant
    
    lazy var distance: String = {
        return distanceInLocalizedUnit(from: CLLocationManager().location?.coordinate ?? .init(), to: restaurant.coordinate)
    }()
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        name = restaurant.name
        priceLevel = restaurant.priceLevel == 0 ? "$" : String(repeating: "$", count: restaurant.priceLevel)
        starRating = restaurant.rating
        reviewCount = restaurant.userRatingsTotal
        photoId = restaurant.photoId
        isOpen = restaurant.isOpen
    }
    
    private func distanceInLocalizedUnit(from currentLocation: CLLocationCoordinate2D, to destinationLocation: CLLocationCoordinate2D) -> String {
        let currentCoordinate = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let destinationCoordinate = CLLocation(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)

        let distanceInMeters = currentCoordinate.distance(from: destinationCoordinate)
        let measurement = Measurement(value: distanceInMeters, unit: UnitLength.meters)

        let locale = Locale.current
        let unit: UnitLength = (locale.measurementSystem == .metric) ? .kilometers : .miles

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1

        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.numberFormatter = numberFormatter
        measurementFormatter.unitStyle = .medium
        measurementFormatter.unitOptions = .providedUnit

        return measurementFormatter.string(from: measurement.converted(to: unit))
    }
}
