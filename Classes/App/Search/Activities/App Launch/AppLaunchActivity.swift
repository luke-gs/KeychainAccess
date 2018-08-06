//
//  AppLaunchActivity.swift
//  MPOLKit
//
//  Created by Herli Halim on 5/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public enum AppLaunchActivity: String, ActivityType {

    case open

    public var name: String {
        return rawValue
    }

    public var parameters: [String : Any] {
        return [:]
    }
}

public class AppLaunchActivityLauncher: BaseActivityLauncher<AppLaunchActivity> { }
