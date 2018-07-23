//
//  SignatureSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public extension Settings {
    
    /// Setting for signature handling
    public static let signature = Setting(title: "Edit Signature",
                                          subtitle: nil,
                                          image: AssetManager.shared.image(forKey: .edit),
                                          type: .button(action: presentVC))

    private static func presentVC(_ viewController: UIViewController, completion: SettingUIUpdateClosure) {
        let vc = SignatureViewController()
        vc.delegate = viewController as? SignatureViewControllerDelegate
        vc.modalPresentationStyle = .formSheet
        viewController.show(vc, sender: viewController)
    }
}
