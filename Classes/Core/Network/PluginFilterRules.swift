//
//  PluginFilterRules.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public enum PluginFilterRule {
    case allowAll
    case whitelist(RulesMatching)
    case blacklist(RulesMatching)
}

public protocol RulesMatching {
    func isMatch(_ urlToMatch: URL) -> Bool
}
