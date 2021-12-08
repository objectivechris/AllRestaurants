//
//  RestaurantViewController.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import UIKit
import SwiftUI

let storyboardIdentifier = "Main"
let tableVCIdentifier = "RestaurantTableViewController"

class RestaurantViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var floatingButton: FloatingButton!
    
    lazy var tableViewController: RestaurantTableViewController = {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: tableVCIdentifier) as! RestaurantTableViewController
        self.addChildVC(viewController)
        return viewController
    }()
    
    lazy var mapViewController: RestaurantMapViewController = {
        let viewController = RestaurantMapViewController(tableViewController.restaurants)
        self.addChildVC(viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC(tableViewController)
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
    
    @IBAction func toggleView(sender: Any) {
        tableViewController.view.isHidden.toggle()
        mapViewController.view.isHidden = !tableViewController.view.isHidden
        
        if tableViewController.view.isHidden {
            floatingButton.style(for: .list)
        } else {
            floatingButton.style(for: .map)
        }
    }
}

