//
//  RestaurantMapViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import MapKit

// San Francisco
let defaultLocation = CLLocationCoordinate2D(latitude: 37.773972, longitude: -122.431297)

class RestaurantMapViewController: UIViewController {
    
    private var mapView: MKMapView!
    private var region = MKCoordinateRegion(center: CLLocationManager().location?.coordinate ?? defaultLocation,
                                            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    private var restaurants: [Restaurant] = []
    
    init(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        mapView = MKMapView()
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        addAnnotations()
        mapView.zoomToFitAnnotations()
    }
    
    func addAnnotations() {
        restaurants.forEach { mapView.addAnnotation(RestaurantAnnotation(restaurant: $0)) }
    }
}

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
        cell.configure(with: RestaurantViewModel(restaurant: selectedAnnotation.restaurant), isMapPin: true)
        cell.center = CGPoint(x: view.bounds.size.width / 2, y: -cell.bounds.size.height * 0.52)
        view.addSubview(cell)
        
        mapView.setCenter(selectedAnnotation.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = .staticPin
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
}
