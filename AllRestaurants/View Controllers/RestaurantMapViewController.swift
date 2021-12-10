//
//  RestaurantMapViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import Combine
import MapKit

// San Francisco
let defaultLocation = CLLocationCoordinate2D(latitude: 37.773972, longitude: -122.431297)

class RestaurantMapViewController: UIViewController {
    
    @IBOutlet private weak var mapView: MKMapView!
    private var region = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? defaultLocation,
                                            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))

    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    private func updateAnnotations(with restaurants: [Restaurant]) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = restaurants.map { RestaurantAnnotation(restaurant: $0) }
        mapView.addAnnotations(annotations)
        
        mapView.zoomToFitAnnotations()
    }
}

// MARK: - Map View Delegate
extension RestaurantMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        let identifier = "RestaurantAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = .staticPin
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let selectedAnnotation = view.annotation as? RestaurantAnnotation else { return }
        view.image = .activePin
        
        mapView.annotations.filter({ $0 as? RestaurantAnnotation != selectedAnnotation }).forEach { annotation in
            mapView.deselectAnnotation(annotation, animated: true)
        }
        
        let cell = UINib(nibName: "RestaurantCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! RestaurantCell
        cell.configure(with: RestaurantViewModel(restaurant: selectedAnnotation.restaurant))
        cell.center = CGPoint(x: view.bounds.size.width / 2, y: -cell.bounds.size.height * 0.52)
        cell.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.addSubview(cell)
        
        mapView.setCenter(selectedAnnotation.coordinate, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    // Update current selected pin view
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = .staticPin
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard mapView.mapWasDragged else { return }
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - RestaurantSearchObserver
extension RestaurantMapViewController: RestaurantSearchObserver {
    
    func didReceiveRestaurants(_ restaurants: [Restaurant]) {
        updateAnnotations(with: restaurants)
    }
}
