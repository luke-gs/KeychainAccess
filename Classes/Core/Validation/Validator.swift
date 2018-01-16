//
//  Validator.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// ValidationError
///
/// - invalid: Indicates that a candidate was deemed invalid. Contains descriptions of all errors if provided. An error with a nil description still represents an invalid candidate.
public enum ValidationError: Error {
    case invalid(descriptions: [String?])
}

/// ValidationState
///
/// - valid: State is valid
/// - invalid: State is invalid, details can be provided in errorDescription
public enum ValidationState {
    case valid
    case invalid(errorDescription: String?)
}

/// A ValidationRuleSet is a general validation object that determines if any of its specifications are invalid.
/// If one is invalid, the whole object is invalid.
public class ValidationRuleSet {
    public let candidate: Any
    public var invalidMessage: String?
    public var rules: [Specification]

    public init(candidate: Any, rules: [Specification], invalidMessage: String? = nil) {
        self.candidate = candidate
        self.rules = rules
        self.invalidMessage = invalidMessage
    }

    public var validityState: ValidationState {

        for rule in rules {
            if rule.isSatisfiedBy(candidate) == false {
                return .invalid(errorDescription: invalidMessage)
            }
        }

        return .valid
    }
}

/// Validatable objects provide a list of values and their applicable validation rules
public protocol Validatable {
    var validationRules: [ValidationRuleSet] { get }
}


/// Validator accepts a Validatable object and validates each ruleset within it.
public class Validator {
    private let candidate: Validatable

    public init(candidate: Validatable) {
        self.candidate = candidate
    }

    public func valid() throws -> Bool {
        var errorMessages = [String?]()

        // Validate all ruleSets.
        for ruleSet in candidate.validationRules {
            if case .invalid(let description) = ruleSet.validityState {
                errorMessages.append(description)
            }
        }

        guard errorMessages.count == 0 else {
            throw ValidationError.invalid(descriptions: errorMessages)
        }

        return true
    }
    
}
