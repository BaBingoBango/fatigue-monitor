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


/// Handles all Firebase-related actions.
///
/// ### Usage
/// All functions are static functions unless otherwise noted.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 16, 2023
///
class FirestoreManager {
    /// Firestore database object
    static var db: Firestore!
    
    /// Connects to Firestore database. Required before calling other functions.
    static func connect() {
        db = Firestore.firestore()
    }
    
    /// Registers user to the database.
    /// Must connect to Firebase by calling `FirestoreManager.connect()` before running.
    static func registerUser(firstName: String, lastName: String,
                             age: Int, groupId: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        var ref: DocumentReference? = nil;
        let docName: String = deviceId ?? "error";
        
        db.collection("users").document(docName).setData([
            "first_name": firstName,
            "last_name": lastName,
            "device_uuid": deviceId,
            "age": age,
            "group_id": groupId
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document \(docName) successfully written!")
            }
        }
    }
    
    /// Retreives the list of users in the group, modifying `userArr` class object.
    /// Must connect to Firebase by calling `FirestoreManager.connect()` before running.
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
                }
            }
    }
    
    @AppStorage("userGroupId") static var userGroupId: String = ""
    /// Retrieves current user's group ID and saves it to app storage
    /// Must connect to Firebase by calling `FirestoreManager.connect()` before running.
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
}

