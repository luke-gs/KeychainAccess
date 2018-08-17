//
//  AppProxyViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View Controller that is just a proxy to opening another app
open class AppProxyViewController: UIViewController {

    /// The URL scheme of the app being opened
    public var appURLScheme: String {
        get {
            return launcher.scheme
        }
    }

    public let navigator: AppURLNavigator

    private let launcher: AnyActivityLauncher

    public init(appURLScheme: String, navigator: AppURLNavigator = .default) {
        launcher = AnyActivityLauncher(scheme: appURLScheme)
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open func launch<T: ActivityType>(_ activity: T) {
        do {
            let wrap = AnyActivity(activity)
            try launcher.launch(wrap, using: AppURLNavigator.default)
        } catch {
            AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Failed to open app", comment: ""))
        }
    }
}
