//
//  ActivityHandler.swift
//  MPOLKit
//
//  Created by Herli Halim on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class ActivityHandler {

    public let supportedActivities: [(scheme: String, host: String?, path: String)]
    public let scheme: String

    public init(scheme: String, supportedActivities: [(scheme: String, host: String?, path: String)]) {
        self.scheme = scheme
        self.supportedActivities = supportedActivities
    }

    open func handle(_ urlString: String, values: [String: Any]?) -> Bool {
        MPLRequiresConcreteImplementation()
    }
}
