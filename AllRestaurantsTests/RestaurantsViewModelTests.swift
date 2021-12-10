//
//  RestaurantsViewModelTests.swift
//  RestaurantsViewModelTests
//
//  Created by Chris Rene on 12/3/21.
//

import XCTest
@testable import AllRestaurants

class RestaurantsViewModelTests: XCTestCase {

    var viewModel: RestaurantViewModel!
    var restaurant: Restaurant!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        viewModel = nil
        restaurant = nil
    }
    
    func testNearbyRestaurantDetails() {
        loadRestaurant(fileName: "NearbySearch")
        
        XCTAssertEqual(viewModel.priceLevel, "$")
        XCTAssertEqual(viewModel.reviewCount, 1154)
        XCTAssertNotEqual(viewModel.starRating, 4.2)
    }
    
    func testCustomSearch() {
        loadRestaurant(fileName: "TextSearch")
        
        XCTAssertEqual(viewModel.priceLevel, "$$")
        XCTAssertEqual(viewModel.reviewCount, 188)
        XCTAssertEqual(viewModel.starRating, 4.3)
    }
    
    private func loadRestaurant(fileName: String) {
        do {
            restaurant = try getModel(fromJSON: fileName)
        } catch {
            XCTFail("Error loading \(fileName)")
        }
        
        viewModel = RestaurantViewModel(restaurant: restaurant)
    }
}


extension XCTestCase {
    enum TestError: Error {
        case fileNotFound
        case unableToDecode
    }

    func getModel<T: Decodable>(fromJSON fileName: String) throws -> T {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("Missing File: \(fileName).json")
            throw TestError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                throw TestError.unableToDecode
            }

            return model
        } catch {
            throw error
        }
    }
}
