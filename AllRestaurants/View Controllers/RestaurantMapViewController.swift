//
//  RestaurantMapViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import UIKit
import SwiftUI

struct RestaurantMapView: View {
  var body: some View {
      VStack {
          Text("Second View").font(.system(size: 36))
          Text("Loaded by SecondView").font(.system(size: 14))
      }
  }
}

class RestaurantMapViewController: UIHostingController<RestaurantMapView> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: RestaurantMapView());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
