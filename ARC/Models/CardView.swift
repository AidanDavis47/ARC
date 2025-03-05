//
//  CardView.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//


import SwiftUI

struct CardView:View{
    let screen: WelcomeScreen
    var body: some View{
        VStack {
            Text(screen.title)
                .font(.headline)
        }
        .foregroundColor(screen.theme.accentColor)
    }
}

struct CardView_Previews: PreviewProvider{
    static var screen = WelcomeScreen.sampleData[0]
    static var previews: some View{
        CardView(screen: screen)
            .background(screen.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
