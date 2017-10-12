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
}


/// Comparison of two validation rules. Rules are considered to be equal if the case
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
public enum ValidatorRule {
    case soft(specification: Specification, message: String)
    case strict(specification: Specification, message: String)
    case submit(specification: Specification, message: String)
}


/// The validator manages the rules and is responsible for validating the candidate.
public class Validator {

    public private(set) var rules: [ValidatorRule]

    private var timer: (timer: Timer, item: BaseFormItem)?

    public init(rules: [ValidatorRule] = []) {
        self.rules = rules
    }

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


    /// MARK: - Add rule methods

    public func addRule(_ rule: ValidatorRule) {
        rules.append(rule)
    }

    public func addSoftRule(_ specification: Specification, message: String) {
        rules.append(.soft(specification: specification, message: message))
    }

    public func addStrictRule(_ specification: Specification, message: String) {
        rules.append(.strict(specification: specification, message: message))
    }

    public func addSubmitRule(_ specification: Specification, message: String) {
        rules.append(.submit(specification: specification, message: message))
    }


    /// MARK: - Validation methods

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
