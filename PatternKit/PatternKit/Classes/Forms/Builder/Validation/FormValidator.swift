//
//  FormValidator.swift
//  MPOLKit
//
//  Created by KGWH78 on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// A set of methods that you must implement for the form to be validatable.
public protocol FormValidatable {

    var validator: FormValidator { get }

    var candidate: Any? { get }

    func reloadLiveValidationState()

    func reloadSubmitValidationState()

    func validateValueForSubmission() -> ValidateResult

}


/// The validator manages the rules and is responsible for validating the candidate.
public class FormValidator {

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


    // MARK: - Validation methods

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
