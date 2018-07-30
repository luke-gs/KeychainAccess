//
//  WhatsNewSetting.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public extension Settings {


    /// Setting for whats new presentation handling
    ///
    /// Presents the whats new screen
    public static let whatsNew = Setting(title: "What's New",
                                         subtitle: nil,
                                         image: nil,
                                         type: .button(action: presentVC))

    private static func presentVC(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        let whatsNewFirstPage = WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
                                                   detail: """
[MPOLA-1584] - Update Login screen to remove highlighting in T&Cs and forgot password.
[MPOLA-1565] - Use manifest for event entity relationships.
[MPOLA-1568] - Pin the logout button to the bottom
[MPOLA-1597] - Update presentation for Terms and Conditions from Settings
[MPOLA-1597] - Update presentation for What's New from Settings
[MPOLA-1597] - Add basic signature capture from Settings
""")

        let whatsNewVC = WhatsNewViewController(items: [whatsNewFirstPage])
        whatsNewVC.isSkippable = true
        whatsNewVC.title = "What's new"

        whatsNewVC.navigationItem.rightBarButtonItem = nil
        whatsNewVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain,
                                                                      target: whatsNewVC, action: #selector(UIViewController.dismissAnimated))
        let navVC = ThemedNavigationController(rootViewController: whatsNewVC)
        navVC.modalPresentationStyle = .pageSheet

        viewController.present(navVC, animated: true, completion: nil)
    }
}

