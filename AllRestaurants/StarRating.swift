//
//  StarRating.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/3/21.
//

import SwiftUI

struct StarRating: View {
    var rating: CGFloat
    
    var body: some View {
        let stars = HStack(spacing: 3) {
            ForEach(0..<5) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        
        stars.overlay(
            GeometryReader { g in
                let width = rating / CGFloat(5) * g.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(Color(uiColor: UIColor.systemGray4))
    }
}


struct StarRating_Previews: PreviewProvider {
    static var previews: some View {
        StarRating(rating: 3.5)
    }
}
