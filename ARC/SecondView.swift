//
//  SecondView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//

import SwiftUI
import RealityKit
import ARKit

struct SecondView : View {
    @State var test: ModelEntity?
    var body: some View {
        Text("SECOND SCREEN")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        
    }
}

#Preview {
    SecondView()
}
