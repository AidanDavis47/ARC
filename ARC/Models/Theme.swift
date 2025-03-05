//
//  Theme.swift
//  ARC
//
//  Created by Aidan Davis and Derek Jolstead on 3/5/25.
//following xcode tutorial from apple

import SwiftUI

enum Theme : String {
    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood //odd name for a color
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
    
    var accentColor : Color{
        switch self{
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return .black
        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
        }
    }
    var mainColor: Color{
        Color(rawValue)
    }
}
