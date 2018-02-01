//
//  ValidationResults.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 9/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Validation Result.
///
/// - valid: This indicates that the item has passed all validation rules.
/// - softInvalid: Indicates an invalid result with a soft validation rule.
/// - strictInvalid: Indicates an invalid result with a strict validation rule.
public enum ValidateResult: Equatable {
    case valid
    case softInvalid(message: String)
    case strictInvalid(message: String)

    /// Returns true if the result is valid.
    ///
    /// - Returns: True if valid.
    public func isValid() -> Bool {
        switch self {
        case .valid:
            return true
        case .softInvalid, .strictInvalid:
            return false
        }
    }

    /// Returns a message if the result is invalid.
    ///
    /// - Returns: String if invalid.
    public func message() -> String? {
        switch self {
        case .valid:
            return nil
        case .softInvalid(let message), .strictInvalid(let message):
            return message
        }
    }

}


/// Comparison of two validation results. Results are considered to be equal if the case
/// and the meesage are the same.
///
/// - Parameters:
///   - lhs: ValidateResult
///   - rhs: ValidateResult
/// - Returns: True if the same. False otherwise.
public func ==(lhs: ValidateResult, rhs: ValidateResult) -> Bool {
    switch (lhs, rhs) {
    case (.valid, .valid):
        return true
    case let (.softInvalid(messageA), .softInvalid(messageB)):
        return messageA == messageB
    case let (.strictInvalid(messageA), .strictInvalid(messageB)):
        return messageA == messageB
    default:
        return false
    }
}
