//
//  TermsAndConditionSetting.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public extension Settings {

    /// Setting for terms and conditions presentation handling
    ///
    /// Presents the terms and conditions screen
    public static let termsAndConditions = Setting(title: "Terms and Conditions",
                                                   subtitle: nil,
                                                   image: nil,
                                                   type: .button(action: presentVC))

    private static func presentVC(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        let tsAndCsVC = TermsConditionsViewController(fileURL: Bundle.main.url(forResource: "termsandconditions", withExtension: "html")!,
                                                      actions: nil)
        tsAndCsVC.title = "Terms and Conditions"
        tsAndCsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: tsAndCsVC,
                                                                     action: #selector(UIViewController.dismissAnimated))
        let navVC = ThemedNavigationController(rootViewController: tsAndCsVC)
        navVC.modalPresentationStyle = .pageSheet

        viewController.present(navVC, animated: true, completion: nil)
    }
}
