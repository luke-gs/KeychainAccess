//
//  WhatsNewSetting.swift
//  CAD
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public extension Settings {


    /// Setting for whats new presentation handling
    ///
    /// Presents the whats new screen
    public static let whatsNew = Setting(title: "What's New",
                                         subtitle: nil,
                                         image: nil,
                                         type: .button(action: presentVC))

    private static func presentVC(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        let whatsNewVC = WhatsNewViewController(items: WhatsNew.detailItems)
        whatsNewVC.isSkippable = true
        whatsNewVC.title = "What's New"

        whatsNewVC.navigationItem.rightBarButtonItem = nil
        whatsNewVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain,
                                                                      target: whatsNewVC, action: #selector(UIViewController.dismissAnimated))
        let navVC = ThemedNavigationController(rootViewController: whatsNewVC)
        navVC.modalPresentationStyle = .pageSheet

        viewController.present(navVC, animated: true, completion: nil)
    }
}
