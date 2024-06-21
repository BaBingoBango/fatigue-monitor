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
import FirebaseAuth


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
    
    /// Edit user information.
    /// Must connect to Firebase by calling `FirestoreManager.connect()` before running.
    static func editUser(age: Int, startDate: Date) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let docName: String = deviceId ?? "error";
        
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
            "device_uuid": deviceId,
            "age": age,
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
    @AppStorage("userFirstName") static var userFirstName: String = ""
    @AppStorage("userAge") static var userAge: Int = 0
    /// Retrieves current user's group ID and saves it to app storage
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func getUserGroupId() {
        // Check if we have a signed-in user!
        guard let user = Auth.auth().currentUser else {
            print("User is not signed in.")
            return
        }
        
        // Get the userID from the signed-in user!
        let userID = user.uid
        
        // Access the UR from the Firestore collection!
        db.collection("users").document(userID).getDocument { (document, error) in
            if let error = error {
                print("Error getting user record: \(error)")
            } else if let document = document, document.exists {
                let oldGroupId = userGroupId
                userGroupId = document.get("group_id") as? String ?? "ERROR"
                userAge = Int(document.get("age") as? Int ?? 0)
                userFirstName = document.get("first_name") as? String ?? ""
                
                if userGroupId != oldGroupId {
                    unsubscribeFromGroup(groupId: oldGroupId)
                    subscribeToGroup(groupId: userGroupId)
                }
            } else {
                print("Error: Document does not exist!")
            }
        }
    }
    
    /// Loads user's heart information and writes it on the `loader` object.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func loadUserInfo(loader: UserInfoLoader) {
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
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
        let docName: String = Utilities.timestampToDateString(timestamp);
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("fatigue_levels").document(docName).setData([
            "device_uuid": deviceId,
            "fatigue_level": fatigueLevel,
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
                print("⬆️ [Fatigue] Uploaded 1 integer.")
            }
        }
    }
    
    /// Uploads heart rate to database.
    /// Called by `didReceiveIBI` in `ViewController`
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadHeartRate(hrMap: [String: Int]) {
        let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970)
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("heart_rates").document(docName).setData([
            "heart_rates": hrMap
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
                print("⬆️ [Heart Rates] Uploaded \(hrMap.count) string-integer pairs.")
            }
        }
    }
    
    /// Uploads skin temperature data to the Firestore database.
    /// Called by `ViewController`.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadSkinTemps(skinTempMap: [String: Float]) {
        let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970)
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("skin_temperatures").document(docName).setData([
            "skin_temperatures": skinTempMap
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
                print("⬆️ [Skin Temps] Uploaded \(skinTempMap.count) string-float pairs.")
            }
        }
    }
    
    /// Uploads GSR data to the Firestore database.
    /// Called by `ViewController`.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadGSRdata(GSRmap: [String: Float]) {
        let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970)
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("gsr_data").document(docName).setData([
            "gsr_data": GSRmap
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
                print("⬆️ [GSR] Uploaded \(GSRmap.count) string-float pairs.")
            }
        }
    }
    
    /// Uploads BVP data to the Firestore database.
    /// Called by `ViewController`.
    /// Must connect to Firebase by calling `FirebaseManager.connect()` before running.
    static func uploadBVPdata(BVPmap: [String: Float]) {
        let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970)
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("bvp_data").document(docName).setData([
            "bvp_data": BVPmap
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
                print("⬆️ [BVP] Uploaded \(BVPmap.count) string-float pairs.")
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
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("fatigue_levels")
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
                            avg[hourOfDay] = (curSum + min((fatigueLevel ?? 100), 100), curCount + 1)
                        }
                    }
                    
                    // observations
                    let hourOfDayNow = Calendar.current.component(.hour, from: Date())
                    let upperBound: Int
                    let lowerBound = UserDefaults.standard.integer(forKey: "xAxisStartHour")
                    
                    if startTime > Date().timeIntervalSince1970 { // future
                        upperBound = lowerBound
                    }
                    else if endTime > Date().timeIntervalSince1970 { // data from today
                        upperBound = min(lowerBound+9, hourOfDayNow+1)
                    }
                    else { // past
                        upperBound = lowerBound+9
                    }
                    
                    if upperBound >= lowerBound {
                        for hr in lowerBound..<upperBound { // CHANGE ME to adjust x-range
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
        
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("survey_responses").document(Utilities.timestampToDateString(timestamp)).setData([
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

