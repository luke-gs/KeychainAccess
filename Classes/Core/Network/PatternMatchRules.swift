//
//  PatternMatchRules.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct PatternMatchRules: RulesMatching {

    public let pattern: String

    public init(pattern: String) {
        self.pattern = pattern
    }

    public func isMatch(_ urlToMatch: URL) -> Bool {
        // TODO: - Not implemented yet.
        // Should be something along the lines of https://developer.chrome.com/extensions/match_patterns.
        return true
    }
}
