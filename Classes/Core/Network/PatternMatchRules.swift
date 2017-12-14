//
//  PatternMatchRules.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Matching based on pattern. Underlying implementation is delegating the work
/// to NSPredicate by evaluating `URL.absoluteString`.
/// - NOTE: It's a naive matching implementation, but then, not built to be used for web browser.
public struct PatternMatchRules: RulesMatching {

    public let pattern: String

    private let predicate: NSPredicate

    public init(pattern: String) {
        self.pattern = pattern
        predicate = NSPredicate(format: "SELF.absoluteString like[cd] %@", pattern)
    }

    public func isMatch(_ urlToMatch: URL) -> Bool {
        return predicate.evaluate(with: urlToMatch)
    }
}

public struct PatternsMatchRules: RulesMatching {

    public let patterns: [String]

    private let predicate: NSPredicate

    public init(patterns: [String]) {
        self.patterns = patterns
        let predicates = patterns.map { NSPredicate(format: "SELF.absoluteString like[cd] %@", $0) }
        predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    }

    public func isMatch(_ urlToMatch: URL) -> Bool {
        return predicate.evaluate(with: urlToMatch)
    }
}
