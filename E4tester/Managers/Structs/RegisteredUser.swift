//
//  User.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/17/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import Foundation

struct RegisteredUser: Identifiable {
    var firstName: String
    var lastName: String
    var age: Int
    var groupId: String
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
}

class RegisteredUserArr: ObservableObject {
    @Published var arr: [RegisteredUser] = []
    
    func getUserFullNames() -> [String] {
        var names: [String] = []
        for i in arr {
            names.append(i.firstName + " " + i.lastName)
        }
        return names
    }
}
