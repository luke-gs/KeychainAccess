//
//  SignatureSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

extension Settings {
    static let signature = Setting(title: "Edit Signature",
                                   subtitle: nil,
                                   image: AssetManager.shared.image(forKey: .nightMode),
                                   type: .button({ viewController in
                                    Settings.presentVC(from: viewController)
                                   }))

    private static func presentVC(from viewController: UIViewController) {
        let vc = SignatureViewController()
        vc.delegate = viewController as? SignatureViewControllerDelegate
        viewController.show(vc, sender: nil)
    }
}
