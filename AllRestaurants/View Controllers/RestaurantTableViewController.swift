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
    var data: (restaurants: [Restaurant], location: Location?) = ([], nil) {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Restaurant>()
            snapshot.appendSections([0])
            snapshot.appendItems(data.restaurants)
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        dataSource = UITableViewDiffableDataSource<Int, Restaurant>(tableView: tableView) { [weak self] tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantCell
            cell.configure(with: RestaurantCellViewModel(restaurant: restaurant, location: self?.data.location))
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
        let restaurant = data.restaurants[indexPath.row]
        let detailView = RestaurantDetailView(viewModel: .init(restaurant: restaurant))
        let hostingController = UIHostingController(rootView: detailView)
        
        if let sheet = hostingController.sheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { context in
                self.view.frame.height * 0.25
            }
            sheet.detents = [fraction]
        }
        
        self.present(hostingController, animated: true, completion: nil)
    }
}
