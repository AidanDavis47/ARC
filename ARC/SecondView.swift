//
//  SecondView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//

import SwiftUI

struct SecondView : View {
    var body: some View {
        Text("SECOND SCREEN")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        
    }
}

#Preview {
    SecondView()
}
