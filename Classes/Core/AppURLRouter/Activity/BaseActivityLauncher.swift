//
//  BaseActivityLauncher.swift
//  MPOLKit
//
//  Created by Herli Halim on 4/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Base class that allows substitution using generic.
/// The idea is to allow explicit limited API. So not just `Any` activity,
/// but only the one declared.
open class BaseActivityLauncher<T: ActivityType>: ActivityLauncherType {

    public typealias Activity = T

    public let scheme: String

    public init(scheme: String) {
        self.scheme = scheme
    }

    open func launch(_ activity: T, using navigator: AppURLNavigator) throws {
        try? navigator.open(scheme, host: nil, path: activity.name, parameters: activity.parameters, completionHandler: nil)
    }
}
