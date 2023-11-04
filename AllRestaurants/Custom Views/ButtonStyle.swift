//
//  FloatingButton.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import UIKit

enum ButtonStyle {
    case map, list
    
    var title: String {
        switch self {
        case .map: return "Map"
        case .list: return "List"
        }
    }
    
    var image: UIImage {
        switch self {
        case .map: return UIImage(systemName: "map")!
        case .list: return UIImage(systemName: "list.bullet")!
        }
    }
    
    mutating func toggle() {
        switch self {
        case .map: self = .list
        case .list: self = . map
        }
    }
}
