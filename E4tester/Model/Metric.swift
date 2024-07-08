//
//  Metric.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/8/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation

enum Metric {
    case fatigue(value: Int)
    case heatStrain(value: Double)
}

enum MetricType {
    case fatigue
    case heatStrain
}
