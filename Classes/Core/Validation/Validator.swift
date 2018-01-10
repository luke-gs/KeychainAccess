//
//  Validator.swift
//  MPOLKit
//
//  Created by Bryan Hathaway on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum ValidationError: Error {
    case invalid(errors: [ValidateResult])
}

public class ValidationRuleSet {
    public let candidate: Any
    public var rules: [Specification]?

    public init(candidate: Any, rules: [Specification]?) {
        self.candidate = candidate
        self.rules = rules
    }

    public var validationResults: [ValidateResult] {
        var results = [ValidateResult]()
        guard let rules = rules else { return [] }

        for rule in rules {
            if rule.isSatisfiedBy(candidate) == false {
                results.append(.strictInvalid(message: ""))
            }
        }

        return results
    }
}

/// Validatable objects provide a list of values and their applicable validation rules
public protocol Validatable {
    var validationRules: [ValidationRuleSet] { get }
}


public class Validator {
    private let candidate: Validatable

    public init(candidate: Validatable) {
        self.candidate = candidate
    }

    public func valid() throws -> Bool {
        var results = [ValidateResult]()

        for ruleSet in candidate.validationRules {
            results.append(contentsOf: ruleSet.validationResults)
        }

        guard results.count == 0 else {
            throw ValidationError.invalid(errors: results)
        }

        return true
    }
    
}
