//
//  FloatingButton.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import UIKit

enum ButtonStyle {
    case map, list
    
    var configuration: UIButton.Configuration {
        var style = UIButton.Configuration.plain()
        style.baseForegroundColor = .white
        style.background.backgroundColor = .allTrailsGreen
        return style
    }
    
    var title: AttributedString {
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 16)
        
        switch self {
        case .map: return AttributedString("Map", attributes: container)
        case .list: return AttributedString("List", attributes: container)
        }
    }
    
    var image: UIImage {
        switch self {
        case .map: return UIImage(named: "map-icon")!
        case .list: return UIImage(named: "list-icon")!
        }
    }
}

class FloatingButton: UIButton {
    
    private var style: ButtonStyle = .map
    
    func style(for buttonStyle: ButtonStyle = .map) {
        style = buttonStyle
        configuration = buttonStyle.configuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
    
    override func updateConfiguration() {
        guard let configuration = configuration else { return }
        
        var updatedConfig = configuration
        
        switch style {
        case .map:
            updatedConfig.attributedTitle = style.title
            updatedConfig.image = style.image
        case .list:
            updatedConfig.attributedTitle = style.title
            updatedConfig.image = style.image
        }
        
        self.configuration = updatedConfig
    }
}
