//
//  PluginFilterRules.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// The rule to be used to filter plugin.
///
/// - allowAll: The plugin will apply to all requests.
/// - whitelist: The plugin will only apply to the specified matches.
/// - blacklist: The plugin will apply to all except to the specified matches.
public enum PluginFilterRule {
    case allowAll
    case whitelist(RulesMatching)
    case blacklist(RulesMatching)
}

public protocol RulesMatching {
    func isMatch(_ urlToMatch: URL) -> Bool
}
