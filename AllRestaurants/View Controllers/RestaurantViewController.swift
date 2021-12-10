//
//  RestaurantViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import Combine
import CoreLocation
import UIKit

fileprivate let storyboardIdentifier = "Main"
fileprivate let tableVCIdentifier = "RestaurantTableViewController"
fileprivate let mapVCIdentifier = "RestaurantMapViewController"

class RestaurantViewController: UIViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var floatingButton: FloatingButton!
    
    private lazy var tableViewController: RestaurantTableViewController = {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: tableVCIdentifier) as! RestaurantTableViewController
        self.addChildVC(viewController)
        addObserver(viewController)
        return viewController
    }()
    
    private lazy var mapViewController: RestaurantMapViewController = {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: mapVCIdentifier) as! RestaurantMapViewController
        self.addChildVC(viewController)
        addObserver(viewController)
        return viewController
    }()
    
    private var state: String? = ""
    
    // Observers & Subscriptions
    private var cancellables = Set<AnyCancellable>()
    private var observations = [ObjectIdentifier: Observation]()
    
    // Location properties
    private var locationManager: CLLocationManager?
    private lazy var geocoder = CLGeocoder()
    private var authorizationDenied: Bool = false
    private var restaurants = [Restaurant]() {
        didSet {
            notifyObservers()
        }
    }
    
    @Published private var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC(mapViewController)
        addChildVC(tableViewController)
        
        searchBar.resignFirstResponder()
        searchBar.delegate = self
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        
        setupBindings()
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
    
    // Subscribe to the searchText for downstream values
    private func setupBindings() {
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.fetchNearbyRestaurants()
                } else {
                    self.searchNearbyRestaurants(withText: query)
                }
            }
            .store(in: &cancellables)
    }
    
    @IBAction func toggleView(_ sender: Any?) {
        tableViewController.view.isHidden.toggle()
        mapViewController.view.isHidden = !tableViewController.view.isHidden
        
        if tableViewController.view.isHidden {
            floatingButton.style(for: .list)
        } else {
            floatingButton.style(for: .map)
        }
    }
    
    private func fetchNearbyRestaurants() {
        guard let location = CLLocationManager().location else {
            restaurants = []
            return
        }
        
        let coordinates = location.coordinate

        // Subscribe to the search publisher and notify observers
        PlacesAPI().fetchNearbyRestaurants(latitude: "\(coordinates.latitude)", longitude: "\(coordinates.longitude)")
            .receive(on: DispatchQueue.main)
            .sink { _  in
            } receiveValue: { [weak self] restaurants in
                self?.restaurants = restaurants
            }
            .store(in: &cancellables)
    }
    
    private func searchNearbyRestaurants(withText text: String) {
        guard let location = CLLocationManager().location else {
            restaurants = []
            return
        }
        
        let coordinates = location.coordinate
        
        // Subscribe to the search publisher and notify observers
        PlacesAPI().search(withText: text, latitude: "\(coordinates.latitude)", longitude: "\(coordinates.longitude)")
            .receive(on: DispatchQueue.main)
            .sink { _  in
            } receiveValue: { [weak self] restaurants in
                self?.filterRestaurants(restaurants)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(_ restaurants: [Restaurant]) {
        guard let state = state else {
            self.restaurants = []
            return
        }
        self.restaurants = restaurants.filter { $0.address.contains(state) }
    }
    
    private func showAlert(title: String = "Uh Oh", message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - LocationManagerDelegate
extension RestaurantViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            fetchNearbyRestaurants()
            authorizationDenied = false
            manager.stopUpdatingLocation()
        default:
            authorizationDenied = true
            restaurants = []
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        authorizationDenied = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                self?.showAlert(title: "Uh Oh", message: error.localizedDescription)
                return
            }
            
            if let placemark = placemarks?.first {
                self?.state = placemark.administrativeArea
            }
        }
        manager.stopUpdatingLocation()
    }
}

// MARK: - UISearchBarDelegate
extension RestaurantViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


// MARK: - Observers
private extension RestaurantViewController {
    struct Observation {
        weak var observer: RestaurantSearchObserver?
    }
    
    func notifyObservers() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.didReceiveRestaurants(restaurants)
            observer.didNotReceiveResults(forText: searchText)
            observer.locationAccessDenied(authorizationDenied)
        }
    }
}

protocol RestaurantSearchObserver: AnyObject {
    func didReceiveRestaurants(_ restaurants: [Restaurant])
    func didNotReceiveResults(forText text: String)
    func locationAccessDenied(_ isDenied: Bool)
}

// Optional Methods
extension RestaurantSearchObserver {
    func didReceiveRestaurants(_ restaurants: [Restaurant]) {}
    func didNotReceiveResults(forText text: String) {}
    func locationAccessDenied(_ isDenied: Bool) {}
}

extension RestaurantViewController {
    func addObserver(_ observer: RestaurantSearchObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }
}
