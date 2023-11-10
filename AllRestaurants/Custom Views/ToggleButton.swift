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
        .frame(width: 100, height: 42)
        .contentShape(RoundedRectangle(cornerRadius: 5))
        .foregroundColor(.white)
        .background(Color.allTrailsGreen)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .shadow(radius: 5)
        .ignoresSafeArea()
    }
}

#Preview {
    ToggleButton(style: .map)
}
