//
//  ValidationRules.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 9/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

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
