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

@objc public protocol Logoutable {
    @objc func logOut()
}

public extension Settings {
    public static let logOut = Setting(title: "Log Off This Device",
                                       subtitle: nil,
                                       image: nil,
                                       type: .button(logOff))

    private static func logOff(_ viewController: UIViewController) {
        viewController.dismiss(animated: true) {
            let window = UIApplication.shared.keyWindow
            let target = window?.target(forAction: #selector(Logoutable.logOut), withSender: nil)

            (target as? Logoutable)?.logOut()
        }
    }
}
