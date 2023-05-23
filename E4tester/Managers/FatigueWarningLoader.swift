//
//  FatigueWarningLoader.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/23/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import Foundation

class FatigueWarningLoader: ObservableObject {
    
    struct FatigueWarning: Identifiable {
        var content: String
        var firstName: String
        var timestamp: Double
        let id = UUID().uuidString
        
        func timeAgo() -> String {
            let now = Date().timeIntervalSince1970
            let diff = now - timestamp
            
            if diff < 60 {
                return "Just now"
            }
            else {
                return Date(timeIntervalSince1970: timestamp).timeAgoDisplay()
            }
        }
    }
    
    var data: [FatigueWarning] = []
    @Published var loading: Bool = false
    
    func addData(content: String,
                 firstName: String,
                 timestamp: Double) {
        data.append(FatigueWarning(content: content,
                                   firstName: firstName,
                                   timestamp: timestamp))
    }
    
    
}

