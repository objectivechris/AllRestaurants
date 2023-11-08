//
//  RestaurantTableViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import CoreLocation
import UIKit
import SwiftUI

private let cellIdentifier = "RestaurantCell"

class RestaurantTableViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    typealias RestaurantLoadingState = (restaurants: [Restaurant], isLoading: Bool)
    private var dataSource: UITableViewDiffableDataSource<Int, Restaurant>?
    var state: RestaurantLoadingState = ([], isLoading: true) {
        didSet {
            updateUI(for: state)
        }
    }
    
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
}

extension RestaurantTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = state.restaurants[indexPath.row]
        let detailView = RestaurantDetailView(viewModel: .init(restaurant: restaurant))
        let hostingController = UIHostingController(rootView: detailView)
        
        if let sheet = hostingController.sheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { context in
                return 250
            }
            sheet.detents = [fraction]
        }
        
        present(hostingController, animated: true, completion: nil)
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
