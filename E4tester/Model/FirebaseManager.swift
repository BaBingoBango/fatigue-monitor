//
//  FirebaseManager.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/16/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging


/// Handles all Firebase-related actions.
///
/// ### Usage
/// All functions are static functions unless otherwise noted.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 6, 2023
///
class FirebaseManager {
    
    /// Firestore database object
    static var db: Firestore!
    
    /// Connects to Firestore database. Required before calling other functions.
    static func connect() {
        db = Firestore.firestore()
    }
    
    /// Registers user to the database.
    /// Must connect to Firebase by calling `FirestoreManager.connect()` before running.
    static func registerUser(firstName: String, lastName: String,
                             age: Int, groupId: String, startDate: Date) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        var ref: DocumentReference? = nil;
        let docName: String = deviceId ?? "error";
        
        db.collection("users").document(docName).setData([
            "first_name": firstName,
            "last_name": lastName,
            "device_uuid": deviceId,
            "age": age,
            "group_id": groupId,
            "start_date": startDate.startOfDay.timeIntervalSince1970
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    @AppStorage("userGroupId") static var userGroupId: String = ""
    /// Retrieves current user's group ID and saves it to app storage
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func getUserGroupId() {
        db.collection("users")
            .whereField("device_uuid", isEqualTo: UIDevice.current.identifierForVendor?.uuidString)
            .order(by: "first_name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        userGroupId = document.get("group_id") as? String ?? "ERROR"
                    }
                }
            }
    }
    
    /// Loads user's heart information and writes it on the `loader` object.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func loadUserInfo(loader: UserInfoLoader) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let docRef = db.collection("user_heart_data").document(deviceId ?? "error")
        loader.loading = true
        
        docRef.getDocument { (document, err) in
            if let document = document, document.exists {
                loader.hr_reserve_cp = document.get("heart_rate_reserve_cp") as? Int ?? 0
                loader.k_value = document.get("k_value") as? Int ?? 0
                loader.rest_hr = document.get("rest_heart_rate") as? Int ?? 0
                loader.total_awc = document.get("total_awc") as? Int ?? 0
                loader.loading = false
            }
            else {
                print("Document not found")
            }
        }
    }
    
    /// Uploads fatigue level to database.
    /// Called by `uploadFatigueLevel` in `ViewController`
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadFatigueLevel(fatigueLevel: Int, timestamp: Double) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        var ref: DocumentReference? = nil;
        let docName: String = (deviceId ?? "Invalid_Device_ID") + "__" + String(timestamp);
        
        db.collection("fatigue_levels").document(docName).setData([
            "device_uuid": deviceId,
            "fatigue_level": fatigueLevel,
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Uploads heart rate to database.
    /// Called by `uploadHeartRate` in `ViewController`
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadHeartRate(heartRate: Int, timestamp: Double) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        var ref: DocumentReference? = nil;
        let docName: String = (deviceId ?? "Invalid_Device_ID") + "__" + String(timestamp);
        
        db.collection("heart_rates").document(docName).setData([
            "device_uuid": deviceId,
            "heart_rate": heartRate,
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Retreives the list of users in the group, modifying `userArr` class object.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func getUsersInGroup(groupId: String, userArr: RegisteredUserArr) {
        userArr.arr.removeAll()
        
        db.collection("users")
            .whereField("group_id", isEqualTo: groupId)
            .order(by: "first_name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        let firstName = document.get("first_name") as? String
                        let lastName = document.get("last_name") as? String
                        let deviceId = document.get("device_uuid") as? String
                        let age = document.get("age") as? Int
                        userArr.arr.append(RegisteredUser(firstName: firstName ?? "ERR",
                                                       lastName: lastName ?? "ERR",
                                                       age: age ?? 0,
                                                       groupId: groupId,
                                                       deviceId: deviceId ?? "ERR"))
                    }
                    userArr.updateLocalStorage()
                }
            }
        
    }
    
    /// Retreives the list of users in the current device's group, modifying `userArr` class object.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func getUsersInGroup(userArr: RegisteredUserArr) {
        getUsersInGroup(groupId: userGroupId, userArr: userArr)
    }
    
    /// Retrieves fatigue data of `deviceId` from `startTime` to `endTime` (inclusive)
    /// and stores it onto `modelData.crew`
    /// - `startTime` and `endTime` must be a double in epoch time (i.e. seconds from 1970)
    static func getFatigueLevels(deviceId: String,
                                 startTime: Double,
                                 endTime: Double,
                                 modelData: ModelData) {
        let groupFirstNames =  UserDefaults.standard.object(forKey: "groupFirstNames") as? [String: String]
        
        modelData.crew.removeAll()
        db.collection("fatigue_levels")
            .whereField("device_uuid", isEqualTo: deviceId)
            .whereField("timestamp", isGreaterThanOrEqualTo: startTime)
            .whereField("timestamp", isLessThanOrEqualTo: endTime)
            .order(by: "timestamp")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    var peer = Peer(id: deviceId,
                                    firstName: (groupFirstNames ?? [:])[deviceId] ?? "Unknown")
                    var range: [Int: (Int, Int)] = [:] // hr : (min, max)
                    var avg: [Int: (Int, Int)] = [:] // hr: (sum, count)
                    
                    // For fatigue levels in range
                    for document in querySnapshot!.documents {
                        let timestamp = document.get("timestamp") as? Double
                        let hourOfDay = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: timestamp ?? 0))
                        let fatigueLevel = document.get("fatigue_level") as? Int
                        
                        if range[hourOfDay] == nil { // first entry of hour
                            range[hourOfDay] = (fatigueLevel ?? -1, fatigueLevel ?? -1)
                            avg[hourOfDay] = (fatigueLevel ?? -1, 1)
                        }
                        else {
                            let (curMin, curMax) = range[hourOfDay] ?? (-1, -1)
                            range[hourOfDay] = (min(curMin, fatigueLevel ?? -1), max(curMax, fatigueLevel ?? -1))
                            let (curSum, curCount) = avg[hourOfDay] ?? (-1, -1)
                            avg[hourOfDay] = (curSum + (fatigueLevel ?? -1), curCount + 1)
                        }
                    }
                    
                    // observations
                    let hourOfDayNow = Calendar.current.component(.hour, from: Date())
                    let upperBound: Int
                    
                    if startTime > Date().timeIntervalSince1970 { // future
                        upperBound = 9
                    }
                    else if endTime > Date().timeIntervalSince1970 { // data from today
                        upperBound = min(18, hourOfDayNow+1)
                    }
                    else {
                        upperBound = 18
                    }
                    
                    if upperBound >= 9 {
                        for hr in 9..<upperBound { // CHANGE ME to adjust x-range
                            let (curSum, curCount) = avg[hr] ?? (-1, -1)
                            let (curMin, curMax) = range[hr] ?? (-1, -1)
                            if curSum >= 0 {
                                 let obs = Peer.Observation(hour_from_midnight: hr, fatigue_level_range: curMin..<curMax, avg_fatigue_level: Double(curSum / curCount))
                                peer.observations.append(obs)
                            }
                            else {
                                let obs = Peer.Observation(hour_from_midnight: hr, fatigue_level_range: 0..<0, avg_fatigue_level: 0)
                                peer.observations.append(obs)
                            }
                        }
                    }
                    
                    modelData.crew.append(peer)
                }
            }
    }
    
    /// Uploads a record of fatigue warning to Firestore
    static func uploadFatigueWarning(_ fatigueLevel: Int) {
        // Data
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "error"
        let timestamp = Date().timeIntervalSince1970
        let content = "may need a break (fatigue \(fatigueLevel)%)"
        let groupId = UserDefaults.standard.string(forKey: "userGroupId")
        let firstName = UserDefaults.standard.string(forKey: "userFirstName")
        
        // Upload
        var ref: DocumentReference? = nil;
        let docName: String = UUID().uuidString;
        db.collection("fatigue_warnings").document(docName).setData([
            "device_id": deviceId,
            "group_id": groupId,
            "first_name": firstName,
            "timestamp": timestamp,
            "content": content
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Loads fatigue warnings from Firebase for the user group.
    static func getFatigueWarnings(loader: FatigueWarningLoader,
                                   numItems: Int) {
        let groupId = UserDefaults.standard.string(forKey: "userGroupId")
        loader.loading = true
     
        db.collection("fatigue_warnings")
            .whereField("group_id", isEqualTo: groupId)
            .order(by: "timestamp", descending: true)
            .limit(to: numItems)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in querySnapshot!.documents {
                        loader.addData(content: document.get("content") as? String ?? "",
                                       firstName: document.get("first_name") as? String ?? "",
                                       timestamp: document.get("timestamp") as? Double ?? 0.0)
                    }
                    loader.loading = false
                }
            }
    }
    
    /// Uploads survey response data
    static func submitSurvey(fatigueLevel: Int) {
        let deviceId = UIDevice().identifierForVendor?.uuidString ?? "error"
        let timestamp = Date().timeIntervalSince1970
        
        var ref: DocumentReference? = nil;
        let docName: String = UUID().uuidString
        
        db.collection("surveys").document(docName).setData([
            "device_id": deviceId,
            "timestamp": timestamp,
            "fatigue_level": fatigueLevel
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Sends a push notification to group members
    static func sendFatigueWarning(firstName: String, fatigueLevel: Int) {
        let title = "High Fatigue: \(firstName)"
        let body = "\(firstName) may need a break (fatigue level \(fatigueLevel)%."
    }
    
    /// Subscribe to push notifications of the group
    /// Called on completing onboarding and editing profile (to be implemented)
    static func subscribeToGroup(groupId: String) {
        Messaging.messaging().subscribe(toTopic: "group_id_\(groupId)")
        print("FirebaseManager.subscribeToGroup(): Subscribed to group_id_\(groupId)")
    }
    
    /// Unsubscribe from push notifications of the group
    /// Called on edit profile (to be implemented)
    static func unsubscribeFromGroup(groupId: String) {
        Messaging.messaging().unsubscribe(fromTopic: "group_id_\(groupId)")
        print("FirebaseManager.unsubscribeFromGroup(): Unsubscribed from group_id_\(groupId)")
    }
}

