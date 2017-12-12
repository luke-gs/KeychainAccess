//
//  Plugin.swift
//  MPOLKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public struct Plugin {

    public let plugin: PluginType
    public let rule: PluginFilterRule

    public init(_ plugin: PluginType, rule: PluginFilterRule = .allowAll) {
        self.plugin = plugin
        self.rule = rule
    }

    /// Check whether the plugin will be applicable to the URL.
    /// - Parameter urlString: The URL to check against the plugin.
    /// - Returns: `true` if it's applicable according to the filter rule.
    /// - Note: Intentionally internal, as it's only going to be used by `APIManager`.
    func isApplicable(to url: URL) -> Bool {
        switch rule {
        case .allowAll:
            return true
        case .blacklist(let matcher):
            return !matcher.isMatch(url)
        case .whitelist(let matcher):
            return matcher.isMatch(url)
        }
    }

}

extension PluginType {

    public func allowAll() -> Plugin {
        return self.withRule(.allowAll)
    }

    public func withRule(_ rule: PluginFilterRule = .allowAll) -> Plugin {
        return Plugin(self, rule: rule)
    }
}
