//
//  LogoffSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//


public extension Settings {

    /// Setting for logging off
    ///
    /// Dismisses the view controller while requesting the logOff manager performs logOff
    public static let logOff = Setting(title: "Log Off This Device",
                                       subtitle: nil,
                                       image: nil,
                                       type: .button(action: logOffAction))

    private static func logOffAction(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        viewController.dismiss(animated: true) {
            LogOffManager.shared.requestLogOff()
        }
    }
}
