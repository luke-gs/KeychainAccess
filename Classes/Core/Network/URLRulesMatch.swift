//
//  URLRulesMatch.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Implementation of `RulesMatching` that's based on `URL` comparison using closure.
public struct URLRulesMatch: RulesMatching {

    public let rules: (URL) -> Bool

    public init(rules: @escaping (URL) -> Bool) {
        self.rules = rules
    }

    public func isMatching(_ urlToMatch: URL) -> Bool {
        return rules(urlToMatch)
    }
}
