//
//  DarkMode.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 5/15/23.
//

import Foundation
import SwiftUI

class DarkMode {
    /// Detects if dark mode is enabled or not.
    static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
