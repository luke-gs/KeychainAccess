//
//  touchIDBiometricsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class touchIDBiometricsViewModel: BiometricsViewModelable {

    public func image(for style: UserInterfaceStyle) -> UIImage? {
        if style.isDark {
            return UIImage(named: "touchID-Dark")
        } else {
            return UIImage(named: "touchID-Light")
        }
    }

    public var title: StringSizable? {
        return "Touch ID Log In"
    }

    public var description: StringSizable? {
        return "Use your Touch ID to log into the app in the future. This setting can be enabled/ disabled from within the Settings menu."
    }

    public var warning: StringSizable? {
        return "You must ensure only your Touch ID is saved on this device. Any Touch ID saved by you or another person can unlock and access this app."
    }

    public var enableText: String? {
        return "Enable Touch ID"
    }

    public var dontEnableText: String? {
        return "Not Now"
    }

    public var enableHandler: ()->()
    public var dontEnableHandler: ()->()

    init(enableHandler: @escaping ()->(), dontEnableHandler: @escaping ()->()) {
        self.enableHandler = enableHandler
        self.dontEnableHandler = dontEnableHandler
    }
}
