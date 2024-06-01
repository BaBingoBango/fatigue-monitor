//
//  DynamicFont.swift
//  E4tester
//
//  Created by Ethan Marshall on 5/24/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation
import SwiftUI

struct DynamicFont: ViewModifier {
    
    let font: Font
    let fontDesign: Font.Design
    let lineLimit: Int
    let minimumScaleFactor: Double
    let padding: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 16.1, *) {
            content
                .font(font)
                .fontDesign(fontDesign) // This modifier is only avaliable on iOS 16.1 and newer.
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
                .padding(.horizontal, padding)
        } else {
            content
                .font(font)
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
                .padding(.horizontal, padding)
        }
    }
}

extension View {
    func dynamicFont(_ font: Font,
                     fontDesign: Font.Design = .default,
                     lineLimit: Int = 1,
                     minimumScaleFactor: Double = 0.5,
                     padding: CGFloat = 15) -> some View {
        
        modifier(DynamicFont(font: font,
                             fontDesign: fontDesign,
                             lineLimit: lineLimit,
                             minimumScaleFactor: minimumScaleFactor,
                             padding: padding))
    }
}
