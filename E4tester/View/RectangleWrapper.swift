//
//  RectangleWrapper.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/4/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation
import SwiftUI

/// A SwiftUI modifier than encloses a view in a rectangle.
///
/// To use this modifier, create an instance of this structure within the `modifier` modifier, as below:
///
/// `.modifier(RectangleWrapper(fixedHeight: 215, color: .green))`
public struct RectangleWrapper: ViewModifier {
    
    var fixedHeight: Int?
    var color: Color = .primary
    var useGradient = false
    var opacity = 1.0
    var cornerRadius = 15.0
    var hideRectangle = false
    var enforceLayoutPriority = false
    
    /// Produces the modified view given the original content.
    public func body(content: Content) -> some View {
        ZStack {
            if !hideRectangle {
                if !useGradient {
                    if fixedHeight == nil {
                        Rectangle()
                            .foregroundColor(color)
                            .opacity(opacity)
                            .cornerRadius(cornerRadius)
                            .layoutPriority(!enforceLayoutPriority ? 0 : -100)
                    } else {
                        Rectangle()
                            .foregroundColor(color)
                            .frame(height: CGFloat(fixedHeight!))
                            .opacity(opacity)
                            .cornerRadius(cornerRadius)
                            .layoutPriority(!enforceLayoutPriority ? 0 : -100)
                    }
                } else {
                    if fixedHeight == nil {
                        Rectangle()
                            .fill(color.gradient)
                            .opacity(opacity)
                            .cornerRadius(cornerRadius)
                            .layoutPriority(!enforceLayoutPriority ? 0 : -100)
                    } else {
                        Rectangle()
                            .fill(color.gradient)
                            .frame(height: CGFloat(fixedHeight!))
                            .opacity(opacity)
                            .cornerRadius(cornerRadius)
                            .layoutPriority(!enforceLayoutPriority ? 0 : -100)
                    }
                }
            }
            
            content
        }
    }
}
