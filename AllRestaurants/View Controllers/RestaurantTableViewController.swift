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

    enum Section: CaseIterable {
        case restaurants
    }
    
    private enum BackgroundState {
        case noLocation
        case noResults(String)
        
        var backgroundView: UIView {
            switch self {
            case .noLocation:
                return UIHostingController(rootView: NoLocationAccess()).view
            case .noResults(let query):
                return UIHostingController(rootView: NoResultsFound(text: query)).view
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    // Diffable data 
    private var dataSource: UITableViewDiffableDataSource<Section, Restaurant>?
    private(set) var restaurants = [Restaurant]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.keyboardDismissMode = .onDrag
        
        configureDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Restaurant>(tableView: tableView) { tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantCell
            cell.configure(with: RestaurantViewModel(restaurant: restaurant))
            return cell
        }
        
        dataSource?.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.restaurants])
        snapshot.appendItems(restaurants, toSection: .restaurants)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureBackground(forState state: BackgroundState) {
        tableView.backgroundView = state.backgroundView
    }
}

// MARK: - RestaurantSearchObserver
extension RestaurantTableViewController: RestaurantSearchObserver {
    
    func didReceiveRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }
    
    func didNotReceiveResults(forText text: String) {
        guard CLLocationManager().authorizationStatus != .notDetermined else { return }
        guard restaurants.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        configureBackground(forState: .noResults(text))
    }
    
    func locationAccessDenied(_ isDenied: Bool) {
        guard isDenied else { return }
        configureBackground(forState: .noLocation)
    }
}
