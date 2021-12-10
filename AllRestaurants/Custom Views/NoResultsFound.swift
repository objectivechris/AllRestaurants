//
//  NoResultsFound.swift
//  AllRestaurants
//
//  Created by Chris Rene on 12/9/21.
//

import SwiftUI

struct NoResultsFound: View {
    
    @State var text: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text("No Results")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We couldn't find anything matching \"\(text)\"")
                .font(.subheadline)
        }
    }
}

struct NoResultsFound_Previews: PreviewProvider {
    static var previews: some View {
        NoResultsFound(text: "Dhgff")
    }
}
