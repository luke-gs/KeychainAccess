//
//  SignatureSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public extension Settings {
    public static let signature = Setting(title: "Edit Signature",
                                          subtitle: nil,
                                          image: AssetManager.shared.image(forKey: .edit),
                                          type: .button(presentVC))

    private static func presentVC(_ viewController: UIViewController) {
        let vc = SignatureViewController()
        vc.delegate = viewController as? SignatureViewControllerDelegate
        vc.modalPresentationStyle = .formSheet
        viewController.show(vc, sender: viewController)
    }
}
