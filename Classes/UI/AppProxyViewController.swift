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
    private var appUrlTypeScheme: String

    /// The generated URL from app scheme
    private var appUrl: URL? {
        return URL(string: "\(appUrlTypeScheme)://")
    }

    public init(appUrlTypeScheme: String) {
        self.appUrlTypeScheme = appUrlTypeScheme
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open func launchApp() {
        if let url = appUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if !success {
                    AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Failed to open app", comment: ""))
                }
            })
        }
    }
}
