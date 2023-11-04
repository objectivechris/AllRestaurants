//
//  RestaurantMapView.swift
//  AllRestaurants
//
//  Created by Chris Rene on 11/1/23.
//

import MapKit
import SwiftUI

struct RestaurantMapView: View {
    
    @StateObject var viewModel: RestaurantViewModel
    @State private var selectedTag: Int?
    
    var body: some View {
        VStack {
            Map(position: $viewModel.position, interactionModes: .all) {
                ForEach(viewModel.restaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(Color.allTrailsGreen)
                }
                UserAnnotation()
                
            }
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
        .mapControls {
            MapUserLocationButton()
                .buttonBorderShape(.circle)
            MapCompass()
        }
        .tint(Color.blue)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    RestaurantMapView(viewModel: RestaurantViewModel())
}
