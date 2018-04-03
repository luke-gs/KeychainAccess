//
//  ActivityHandler.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class ActivityHandler {

    public let supportedPaths: [String]
    public let scheme: String
    public let host: String?

    public init(scheme: String, host: String? = nil, supportedPaths: [String]) {
        self.scheme = scheme
        self.host = host
        self.supportedPaths = supportedPaths
    }

    open func handle(_ urlString: String, values: [String: Any]?) -> Bool {
        MPLRequiresConcreteImplementation()
    }
}

extension AppURLNavigator {

    /// Convenience method to register this handler to the `AppURLNavigator`
    ///
    /// - Parameter navigator: The navigator to attach to.
    /// - Returns: `true` or `false` to indicate whether this activity has been registered
    ///             correctly to the specified `AppURLNavigator`.
    @discardableResult public func register(_ activityHandler: ActivityHandler) -> Bool {

        var success = true
        let scheme = activityHandler.scheme
        let host = activityHandler.host
        for path in activityHandler.supportedPaths {
            do {
                try register(scheme, host: host, path: path, handler: {
                    return activityHandler.handle($0, values: $1)
                })
            } catch {
                success = false
            }

        }

        return success
    }

}
