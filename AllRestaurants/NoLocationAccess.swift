//
//  NoLocationAccess.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/7/21.
//

import SwiftUI

struct NoLocationAccess: View {
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Find restaurants near you")
                .font(.headline)
            
            Text("AllRestaurants to use your location to show you nearby trails.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 10))
            
            Button(action: openSettings) {
                Text("Go to settings")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(10)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .background(Color("AllGreen", bundle: nil))
            .cornerRadius(4)
            .padding([.horizontal], 20)
            
            Spacer()
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct NoLocationAccess_Previews: PreviewProvider {
    static var previews: some View {
        NoLocationAccess()
    }
}
