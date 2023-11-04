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
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var buttonContainerView: UIView!
    
    private lazy var tableViewController: RestaurantTableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RestaurantTableViewController") as! RestaurantTableViewController
        self.addChildVC(viewController)
        return viewController
    }()
    
    private lazy var mapViewController: UIHostingController = {
        let hostingController = UIHostingController(rootView: RestaurantMapView(viewModel: self.viewModel))
        self.addChildVC(hostingController)
        return hostingController
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel = RestaurantViewModel()
    private var style = ButtonStyle.map
    
    @Published private var searchText: String?
    @Published private var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC(mapViewController)
        addChildVC(tableViewController)
        
        setupBindings()
        
        searchBar.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            showAlert(title: "Location Disabled", message: "Please review your location permissions in Settings")
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        let toggleButton = UIHostingController(rootView: ToggleButton(style: style))
        toggleButton.view.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleView)))
        addChild(toggleButton)
        buttonContainerView.addSubview(toggleButton.view)
        
        
        NSLayoutConstraint.activate([
            toggleButton.view.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            toggleButton.view.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
        ])
        
        toggleButton.didMove(toParent: self)
    }
    
    private func addChildVC(_ childVC: UIViewController) {
        addChild(childVC)
        
        containerView.addSubview(childVC.view)
        
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        childVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        childVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        childVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        childVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        childVC.didMove(toParent: self)
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
                guard let self = self else { return }
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
                self?.tableViewController.restaurants = rest
            }
            .store(in: &subscriptions)
    }
    
    @IBAction func toggleView(_ sender: Any?) {
        tableViewController.view.isHidden.toggle()
        mapViewController.view.isHidden = !tableViewController.view.isHidden
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
        present(alert, animated: true, completion: nil)
    }
}

extension RestaurantViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            fetchNearbyRestaurants()
        default:
            showAlert(message: "Please check your location permissions in Settings.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Update Error", message: error.localizedDescription)
    }
}

extension RestaurantViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
