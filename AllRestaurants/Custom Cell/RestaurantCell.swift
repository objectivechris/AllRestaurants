//
//  RestaurantCell.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/5/21.
//

import SwiftUI
import Foundation
import UIKit

class RestaurantCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var priceLevelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(with model: RestaurantCellViewModel) {
        nameLabel.text = model.name
        placeImageView.image = UIImage(named: "resty")!
        reviewCountLabel.text = "(\(model.reviewCount.abbreviated))"
        priceLevelLabel.text = "\(model.priceLevel)"
        statusLabel.text = model.distance
        Task {
            try await placeImageView.load(url: GMEndpoint.photo(model.photoId).url, placeholder: nil)
        }
        
        placeImageView.layer.cornerRadius = placeImageView.frame.width / 2
        
        let controller = UIHostingController(rootView: StarRating(rating: model.starRating))
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controller.view)
                
        controller.view.leadingAnchor.constraint(equalTo: starRatingView.leadingAnchor).isActive = true
        controller.view.trailingAnchor.constraint(equalTo: starRatingView.trailingAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: starRatingView.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: starRatingView.bottomAnchor).isActive = true
        
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        containerView.layer.borderWidth = 1.0
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 12
    }
}

