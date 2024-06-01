//
//  UserExistenceChecker.swift
//  E4tester
//
//  Created by Ethan Marshall on 5/30/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserExistenceChecker: ObservableObject {
    @Published var userExists: Bool = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init(uid: String) {
        startListening(uid: uid)
    }
    
    func startListening(uid: String) {
        print("😻 started listening...")
        listener?.remove()
        
        let documentRef = db.collection("users").document(uid)
        
        listener = documentRef.addSnapshotListener { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot {
                print("😻 user exists? -> \(documentSnapshot.exists)")
                self.userExists = documentSnapshot.exists
            } else {
                print("Error listening for document existence: \(error?.localizedDescription ?? "Unknown error")")
                self.userExists = false
            }
        }
    }

    deinit {
        listener?.remove()
        print("😻 stopped listening!")
    }
}
