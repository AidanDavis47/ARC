//
//  welcome.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//following xcode tutorial by apple

import Foundation


struct WelcomeScreen{
    var title: String
    var theme: Theme
}

extension WelcomeScreen{
    static let sampleData: [WelcomeScreen] =
    [
        WelcomeScreen(title: "Screen1", theme: .yellow),
        WelcomeScreen(title: "Screen2", theme: .oxblood),
        WelcomeScreen(title: "Screen3", theme: .navy),
    ]
}
