//
//  Validator.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A set of methods that you must implement for the form to be validatable.
public protocol FormValidatable {

    var validator: Validator { get }

    var candidate: Any? { get }

    func reloadLiveValidationState()

    func reloadSubmitValidationState()

    func validateValueForSubmission() -> ValidateResult

}


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


/// The validator manages the rules and is responsible for validating the candidate.
public class Validator {

    /// A collection of rules.
    public private(set) var rules: [ValidatorRule]

    /// Initialize a validator with a collection of rules.
    ///
    /// - Parameter rules: A collection of rules.
    public init(rules: [ValidatorRule] = []) {
        self.rules = rules
    }

    /// Validates the candidate against the stored rules. The validation process
    /// stops immediately if it fails against a strict or a submit rules, and its result
    /// is returned. If passes strict and submit validations, but has a soft invalid result,
    /// the first soft invalid result is returned.
    ///
    /// - Parameters:
    ///   - candidate: The candidate to be validated.
    ///   - checkHardRule: True to validate using hard rules.
    ///   - checkSoftRule: True to validate using soft rules.
    ///   - checkSubmitRule: True to validate using submit rules.
    /// - Returns: Valid result if the candidcate passes all the rules. Otherwise returns
    ///            the first invalid result.
    public func validate(_ candidate: Any?, checkHardRule: Bool, checkSoftRule: Bool, checkSubmitRule: Bool) -> ValidateResult {
        var results = [ValidateResult]()

        for rule in rules {
            switch rule {
            case .soft(let specication, let message):
                if checkSoftRule && !specication.isSatisfiedBy(candidate) {
                    results.append(.softInvalid(message: message))
                }
            case .strict(let specification, let message):
                if checkHardRule && !specification.isSatisfiedBy(candidate) {
                    return .strictInvalid(message: message)
                }
            case .submit(let specification, let message):
                if checkSubmitRule && !specification.isSatisfiedBy(candidate) {
                    return .strictInvalid(message: message)
                }
            }
        }

        if results.isEmpty {
            return .valid
        }

        return results[0]
    }

    /// Add a rule to validator.
    ///
    /// - Parameter rule: The rule.
    public func addRule(_ rule: ValidatorRule) {
        rules.append(rule)
    }


    /// MARK: - Validation methods

    private var timer: (timer: Timer, item: BaseFormItem)?

    @discardableResult public func validateAndUpdateErrorIfNeeded(_ candidate: Any?, shouldInstallTimer: Bool, checkSubmitRule: Bool, forItem item: BaseFormItem) -> Bool {
        invalidateTimer()

        if candidate != nil || checkSubmitRule {
            let result = self.validate(candidate, checkHardRule: true, checkSoftRule: true, checkSubmitRule: checkSubmitRule)

            switch result {
            case .strictInvalid(let message):
                item.focusedText = message
                if shouldInstallTimer {
                    installTimer(forItem: item)
                }
                return false
            case .softInvalid(let message):
                item.focusedText = message
            case .valid:
                item.focusedText = nil
            }
        } else {
            item.focusedText = nil
        }

        return true
    }

    private func installTimer(forItem item: BaseFormItem) {
        invalidateTimer()
        timer = (Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(endTimer), userInfo: nil, repeats: false), item)
    }

    private func invalidateTimer() {
        if let timer = timer {
            timer.timer.invalidate()
            self.timer = nil
        }
    }

    @objc private func endTimer() {
        let oldTimer = timer

        invalidateTimer()

        guard let item = oldTimer?.item, let validatable = item as? FormValidatable else { return }

        validateAndUpdateErrorIfNeeded(validatable.candidate, shouldInstallTimer: false, checkSubmitRule: false, forItem: item)
    }

}
