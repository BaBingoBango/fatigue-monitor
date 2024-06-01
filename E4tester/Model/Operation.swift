//
//  Operation.swift
//  E4tester
//
//  Created by Ethan Marshall on 5/30/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation

/// An operation that takes time and can fail, such as a network request.
struct Operation {
    
    // MARK: Variables
    /// The status of the operation.
    var status: OperationStatus = .notStarted
    /// A message describing this operation's progress.
    var progressMessage: String = "Loading..."
    /// An error message produced by the operation failing.
    var errorMessage: String = "An error occurred."
    /// Whether or not an error message is being displayed.
    var isShowingErrorMessage = false
    
    // MARK: Functions
    /// Sets the operation into the failure state and presents the error message.
    mutating func setError(message: String) {
        errorMessage = message
        status = .failure
        isShowingErrorMessage = true
    }
}

/// The status of an operation that takes time and can fail, such as a network request.
enum OperationStatus {
    /// The case in which the operation has not yet been attempted.
    case notStarted
    
    /// The case in which the operation is currently underway.
    case inProgress
    
    /// The case in which the operation has completed successfully.
    case success
    
    /// The case in which the operation is complete but has failed.
    case failure
}
