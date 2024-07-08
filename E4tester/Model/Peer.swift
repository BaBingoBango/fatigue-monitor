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
        return id.uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    
    var id: UUID = UUID()
    
    @Published var first_name: String = "Unknown"
    var fatigue_level = 0
    var last_update: Int = 0
    var observations: [Observation] = []
    var heatObservations: [HeatStrainObservation] = []
    
    struct Observation: Codable, Hashable, Identifiable {
        var id = UUID()
        var hour_from_midnight: Int
        var fatigue_level_range: Range<Int>
        var avg_fatigue_level: Double
    }
    
    struct HeatStrainObservation: Codable, Hashable, Identifiable {
        var id = UUID()
        var hourFromMidnight: Int
        var heatStrainRange: Range<Double>
        var averageHeatStrain: Double
    }
    
    init(id: String, firstName: String) {
        self.id = UUID()
        self.first_name = firstName
    }
}
