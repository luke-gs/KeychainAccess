//
//  Validator.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 8/1/18.
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


/// The rule for validation.
///
/// - soft: This is used for live validation of text without preventing text input.
/// - strict: This will prevent the text input if it doesn't pass the strict rule.
/// - submit: Validations on submission or on end editing.
public enum ValidatorRule: Equatable {
    case soft(specification: Specification, message: String)
    case strict(specification: Specification, message: String)
    case submit(specification: Specification, message: String)
}


/// Comparion of two rules. Rules are considered the same if the case, spec and message
/// are equal.
///
/// - Parameters:
///   - lhs: ValidatorRule
///   - rhs: ValidatorRule
/// - Returns: True if the same. False otherwise.
public func ==(lhs: ValidatorRule, rhs: ValidatorRule) -> Bool {
    switch (lhs, rhs) {
    case (.soft(let specification1, let message1), .soft(let specification2, let message2)):
        return specification1 == specification2 && message1 == message2
    case (.strict(let specification1, let message1), .strict(let specification2, let message2)):
        return specification1 == specification2 && message1 == message2
    case (.submit(let specification1, let message1), .submit(let specification2, let message2)):
        return specification1 == specification2 && message1 == message2
    default:
        return false
    }
}
