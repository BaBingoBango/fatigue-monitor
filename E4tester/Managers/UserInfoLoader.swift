//
//  UserInfoLoader.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/19/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import Foundation

class UserInfoLoader: ObservableObject {
    @Published var hr_reserve_cp: Int = 16
    @Published var k_value: Int = 15
    @Published var rest_hr: Int = 65
    @Published var total_awc: Int = 200
    @Published var loading: Bool = false
}
