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
            Map(position: $viewModel.position) {
                ForEach(viewModel.restaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(Color.allTrailsGreen)
                }
                UserAnnotation()
                    .foregroundStyle(.blue)
                
            }
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
        .overlay(alignment: .bottomTrailing) {
            VStack {
                MapUserLocationButton()
            }
            .padding(.trailing, 10)
            .buttonBorderShape(.circle)
            .tint(Color.blue)
        }
    }
}

#Preview {
    RestaurantMapView(viewModel: RestaurantViewModel())
}
