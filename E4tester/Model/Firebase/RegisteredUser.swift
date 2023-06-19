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
    let id = UUID().uuidString // Identifiable
}

class RegisteredUserArr: ObservableObject {
    @Published var arr: [RegisteredUser] = []
    
    func getUserFullNames() -> [String] {
        var names: [String] = []
        for i in arr {
            names.append(i.firstName + " " + i.lastName)
        }
        updateLocalStorage()
        
        return names
    }
    
    func updateLocalStorage() {
        if arr.isEmpty {
            return
        }
        
        var groupFirstNames: [String: String] = [:] // id: first name
        
        for user in arr {
            groupFirstNames[user.deviceId] = user.firstName
        }
        
        UserDefaults.standard.set(groupFirstNames, forKey: "groupFirstNames")
    }
}
