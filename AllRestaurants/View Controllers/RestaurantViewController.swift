//
//  RestaurantViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import Combine
import SwiftUI
import UIKit
import MapKit

class RestaurantViewController: UIViewController {
    
    private lazy var tableViewController: RestaurantTableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RestaurantTableViewController") as! RestaurantTableViewController
        addChildVC(viewController)
        return viewController
    }()
    
    private lazy var mapViewController: UIHostingController = {
        let hostingController = UIHostingController(rootView: RestaurantMapView(viewModel: self.viewModel))
        addChildVC(hostingController)
        return hostingController
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        return search
    }()
    
    private lazy var toggleButton: UIHostingController = {
        let button = UIHostingController(rootView: ToggleButton(style: style))
        return button
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private let viewModel = RestaurantViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private var style: ButtonStyle = .map {
        didSet {
            switch style {
            case .map:
                display(tableViewController)
            case .list:
                display(mapViewController)
            }
        }
    }
    
    @Published private var searchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nearby Restaurants"
        
        setupToggleButton()
        setupSearchBar()
        setupBindings()
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            showAlert(title: "Location Disabled", message: "Please review your location permissions in Settings")
        }
    }
    
    private func setupBindings() {
        viewModel.$error
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(message: error.errorDescription ?? "Unknown Error")
            }
            .store(in: &subscriptions)
        
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .compactMap({ $0 })
            .sink { [weak self] query in
                guard let self else { return }
                if query.isEmpty {
                    self.fetchNearbyRestaurants()
                } else {
                    self.searchForRestaurants(withText: query)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$restaurants
            .receive(on: RunLoop.main)
            .sink { [weak self] rest in
                guard let self else { return }
                self.tableViewController.state = (rest, self.viewModel.isFetching)
            }
            .store(in: &subscriptions)
    }
    
    private func setupToggleButton() {
        addChildVC(toggleButton)
        toggleButton.view.backgroundColor = .clear
        toggleButton.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleView)))
        toggleButton.view.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toggleButton.view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20).isActive = true
    }
    
    private func setupSearchBar() {
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.tintColor = .allTrailsGreen
        searchController.searchBar.placeholder = "Search for a restaurant"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func display(_ viewController: UIViewController) {
        // Remove the currently displayed view controller
        if let currentViewController = children.filter({ !($0 is UIHostingController<ToggleButton>) }).first {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        addChildVC(viewController)
    }
    
    @objc private func toggleView() {
        style.toggle()
    }
    
    private func addChildVC(_ childVC: UIViewController) {
        addChild(childVC)
        childVC.view.frame = view.bounds
        if childVC is UIHostingController<ToggleButton> {
            view.addSubview(childVC.view)
        } else {
            view.insertSubview(childVC.view, belowSubview: toggleButton.view)
        }
        childVC.didMove(toParent: self)
    }
    
    private func fetchNearbyRestaurants() {
        Task {
            try await viewModel.fetchNearbyRestaurants(fromLocation: locationManager.location)
        }
    }
    
    private func searchForRestaurants(withText text: String) {
        Task {
            try await viewModel.searchForRestaurants(fromLocation: locationManager.location, withText: text)
        }
   }
    
    private func showAlert(title: String = "Uh Oh", message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension RestaurantViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            fetchNearbyRestaurants()
        default:
            showAlert(message: "Please check your location permissions in Settings.")
        }
    }
}

extension RestaurantViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        fetchNearbyRestaurants()
    }
}
