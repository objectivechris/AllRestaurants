//
//  RestaurantTableViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import CoreLocation
import UIKit
import MapKit
import SwiftUI

private let cellIdentifier = "RestaurantCell"

class RestaurantTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    typealias RestaurantLoadingState = (restaurants: [Restaurant], isLoading: Bool)
    var state: RestaurantLoadingState = ([], isLoading: true) {
        didSet {
            updateUI(for: state)
        }
    }
    
    private var dataSource: UITableViewDiffableDataSource<Int, Restaurant>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        dataSource = UITableViewDiffableDataSource<Int, Restaurant>(tableView: tableView) { tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantCell
            cell.configure(with: RestaurantCellViewModel(restaurant: restaurant))
            return cell
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    private func updateUI(for state: RestaurantLoadingState) {
        let (restaurants, isLoading) = state
        
        if isLoading {
            configureBackground(forState: .loading)
        } else if restaurants.isEmpty {
            configureBackground(forState: .noResults)
        } else {
            tableView.backgroundView = nil
        }
        
        // Update the data source snapshot regardless of loading state
        var snapshot = NSDiffableDataSourceSnapshot<Int, Restaurant>()
        snapshot.appendSections([0])
        snapshot.appendItems(restaurants, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentDetailView(forRestaurant restaurant: Restaurant) {
        var detailView = RestaurantDetailView(viewModel: .init(restaurant: restaurant))
        let hostingController = UIHostingController(rootView: detailView)
        
        if let sheet = hostingController.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in 250 }
            sheet.detents = [customDetent]
        }
        
        navigationController?.present(hostingController, animated: true)

        Task {
            do {
                let route = try await calculateRoute(for: restaurant)
                await MainActor.run {
                    detailView.route = route
                    hostingController.rootView = detailView
                }
            }
        }
    }
    
    private func calculateRoute(for restaurant: Restaurant) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = .forCurrentLocation()
        request.destination = MKMapItem(placemark: .init(coordinate: restaurant.coordinate))

        let directions = MKDirections(request: request)

        return try await withUnsafeThrowingContinuation { continuation in
            directions.calculate { response, error in
                if let route = response?.routes.first {
                    continuation.resume(returning: route)
                }
            }
        }
    }
}

extension RestaurantTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = state.restaurants[indexPath.row]
        presentDetailView(forRestaurant: restaurant)
    }
}

extension RestaurantTableViewController {
    private enum BackgroundState {
        case loading
        case success
        case noResults
        
        var backgroundView: UIView? {
            switch self {
            case .loading:
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.startAnimating()
                return activityIndicator
            case .success:
                return nil
            case .noResults:
                return UIHostingController(rootView: NoResultsFound()).view
            }
        }
    }
    
    private func configureBackground(forState state: BackgroundState) {
        tableView.backgroundView = state.backgroundView
    }
}
