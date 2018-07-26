//
//  LogoutSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

//
//  Settings+Logout.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// Protocol to handle logout
/// Can be used via responder chain
///
/// Also used for logging out via the settings
@objc public protocol Logoutable {

    /// Called on a logout action
    /// Do session cleanup or presentation here
    @objc func logOut()
}

public extension Settings {

    /// Setting for logging out
    ///
    /// Calls `logOut()` of `Logoutable` protocol up the responder chain from `UIApplication.shared.keyWindow`
    public static let logOut = Setting(title: "Log Off This Device",
                                       subtitle: nil,
                                       image: nil,
                                       type: .button(action: logOff))

    private static func logOff(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        viewController.dismiss(animated: true) {
            let window = UIApplication.shared.keyWindow
            let target = window?.target(forAction: #selector(Logoutable.logOut), withSender: nil)
            (target as? Logoutable)?.logOut()
        }
    }
}
