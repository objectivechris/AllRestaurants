//
//  RestaurantViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import Combine
import CoreLocation
import UIKit
import SwiftUI

private let identifier = "RestaurantCell"

class RestaurantViewController: UIViewController {

    enum Section: CaseIterable {
        case restaurants
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var floatingButton: FloatingButton!
    
    private var locationManager: CLLocationManager?
    private var dataSource: UITableViewDiffableDataSource<Section, Restaurant>!
    private var cancelleables = Set<AnyCancellable>()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
        
    private(set) var restaurants = [Restaurant]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        
        configureDataSource()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Restaurant>(tableView: tableView) { tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RestaurantCell
            cell.configure(with: RestaurantViewModel(restaurant: restaurant))
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.restaurants])
        snapshot.appendItems(restaurants, toSection: .restaurants)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func fetchNearbyRestaurants(from location: CLLocation?) {
        guard let location = location else { return }
        let coordinates = location.coordinate
        
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
        
        PlacesAPI().fetchNearbyRestaurants(latitude: "\(coordinates.latitude)", longitude: "\(coordinates.longitude)")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _  in
                self?.activityIndicator.stopAnimating()
            } receiveValue: { [weak self] restaurants in
                self?.restaurants = restaurants
                print(restaurants)
            }
            .store(in: &cancelleables)
    }
    
    private func showAlert(title: String = "Uh Oh", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showNoLocationView() {
        let controller = UIHostingController(rootView: NoLocationAccess())
        tableView.backgroundView = controller.view
    }
}

extension RestaurantViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            fetchNearbyRestaurants(from: manager.location)
            manager.stopUpdatingLocation()
        default:
            showNoLocationView()
            restaurants = []
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Update Error", message: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        self.fetchNearbyRestaurants(from: location)
        manager.stopUpdatingLocation()
    }
}
