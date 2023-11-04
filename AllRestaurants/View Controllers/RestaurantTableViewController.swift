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
        
    private var dataSource: UITableViewDiffableDataSource<Int, Restaurant>?
    var restaurants = [Restaurant]() {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Restaurant>()
            snapshot.appendSections([0])
            snapshot.appendItems([])
            dataSource?.apply(snapshot, animatingDifferences: true)
            
            snapshot.appendItems(restaurants)
            dataSource?.apply(snapshot, animatingDifferences: true)
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
    
    private func configureBackground(forState state: BackgroundState) {
        tableView.backgroundView = state.backgroundView
    }
}

extension RestaurantTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = restaurants[indexPath.row]
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let nav = UINavigationController(rootViewController: viewController)
        viewController.title = "\(restaurant.name)"
        if let sheet = nav.sheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { context in
                self.view.frame.height * 0.25
            }
            sheet.detents = [fraction]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        self.present(nav, animated: true, completion: nil)
    }
}
