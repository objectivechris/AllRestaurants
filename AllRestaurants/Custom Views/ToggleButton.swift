//
//  ToggleButton.swift
//  AllRestaurants
//
//  Created by Chris Rene on 10/31/23.
//

import SwiftUI

struct ToggleButton: View {
    
    @State var style: ButtonStyle
    
    var body: some View {
        Button(action: { style.toggle() }) {
            HStack {
                Image(uiImage: style.image)
                    .renderingMode(.template)
                
                Text(style.title)
                    .bold()
            }
        }
        .foregroundColor(.white)
        .frame(width: 100, height: 42)
        .background(Color.allTrailsGreen)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .shadow(radius: 5)
        .ignoresSafeArea()
    }
}

#Preview {
    ToggleButton(style: .map)
}
