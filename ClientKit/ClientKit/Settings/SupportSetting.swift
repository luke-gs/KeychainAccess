//
//  SupportSetting.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public extension Settings {
    public static let support = Setting(title: "Support",
                                        subtitle: Settings.formattedSupportString(),
                                        image: nil,
                                        type: .button({_ in }))

    private static func formattedSupportString() -> String {
        let bundle = Bundle.main
        let bundleVersion   = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let buildNumber     = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return  NSLocalizedString("Version " + bundleVersion + " #" +  buildNumber, comment: "")
    }
}
