//
//  Peer.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

class Peers : ObservableObject {
    @Published var crew: [Peer] = []
}

class Peer : Identifiable, Hashable, ObservableObject {
    static func == (lhs: Peer, rhs: Peer) -> Bool {
        return lhs.id == rhs.id
    }
    
    var identifier: String {
        return id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    
    var id: String = "" // user_id
    
    @Published var first_name: String = "Unknown"
    var fatigue_level = 0
    var last_update: Int = 0
    var observations: [Observation] = []
    
    struct Observation: Codable, Hashable {
        var hour_from_midnight: Int
        var fatigue_level_range: Range<Int>
        var avg_fatigue_level: Double
    }
    
    init(id: String, firstName: String) {
        self.id = id
        self.first_name = firstName
    }
}
