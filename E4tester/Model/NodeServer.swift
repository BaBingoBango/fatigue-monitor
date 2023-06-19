//
//  NodeServer.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 6/15/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import Foundation

class NodeServer {
    static let serverProtocol = "http"
    static let serverIp = "35.193.174.156"
    static let serverPort: Int = 3001
    
    /// Sends a push notification to group members
    static func sendFatigueWarning(firstName: String, fatigueLevel: Int, groupId: String) {
        // Data
        let title = "High Fatigue: \(firstName)"
        let body = "\(firstName) may need a break. (fatigue level \(fatigueLevel)%)"
        let json: [String: String] = ["messageTitle" : title,
                                      "messageBody" : body,
                                      "groupID" : groupId]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // Prepare request
        let url = URL(string: "\(serverProtocol)://\(serverIp):\(serverPort)/send-fatigue-warning")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Send request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                print(data)
            }
        }
        task.resume()
    }

}
