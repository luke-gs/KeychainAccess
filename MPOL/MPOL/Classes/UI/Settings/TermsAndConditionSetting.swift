//
//  TermsAndConditionSetting.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public extension Settings {

    /// Setting for terms and conditions presentation handling
    ///
    /// Presents the terms and conditions screen
    public static let termsAndConditions = Setting(title: "Terms and Conditions",
                                                   subtitle: nil,
                                                   image: nil,
                                                   type: .button(action: presentVC))

    private static func presentVC(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {

        do {
            
            let lightURL = Bundle.main.url(forResource: "LightModeStyle", withExtension: "css")!
            let darkURL = Bundle.main.url(forResource: "DarkModeStyle", withExtension: "css")!
            let styleMap: [UserInterfaceStyle: URL] = [.light: lightURL, .dark: darkURL]
            
            let tsAndCsVC = try HTMLTextViewController(title: NSLocalizedString("Terms and Conditions", comment: "Title"),
                                                            htmlURL: TermsAndConditions.url,
                                                            styleMap: styleMap,
                                                            actions: nil)

            tsAndCsVC.title = "Terms and Conditions"
            tsAndCsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close",
                                                                         style: .plain,
                                                                         target: tsAndCsVC,
                                                                         action: #selector(UIViewController.dismissAnimated))

            let navVC = ModalNavigationController(rootViewController: tsAndCsVC)
            navVC.modalPresentationStyle = .pageSheet

            viewController.present(navVC, animated: true, completion: nil)

        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
