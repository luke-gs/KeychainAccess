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
        let vc = SignatureViewController(image: UserPreferenceManager.shared.preference(for: .signaturePreference)?.image)
        vc.delegate = viewController as? SignatureViewControllerDelegate
        vc.modalPresentationStyle = .formSheet
        viewController.show(vc, sender: viewController)
    }
}


extension SettingsViewController: SignatureViewControllerDelegate {
    public func controllerDidCancelIn(_ controller: SignatureViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    public  func controller(_ controller: SignatureViewController, didFinishWithSignature signature: UIImage?) {
        if let image = signature,
            let userPreference = UserPreference(applicationName: User.appGroupKey, preferenceTypeKey: .signaturePreference, image: image) {
            try? UserPreferenceManager.shared.updatePreference(userPreference)
            navigationController?.popViewController(animated: true)
        }
        
    }
}

extension UserPreferenceKey {
    public static let signaturePreference = UserPreferenceKey("signaturePreference")
}
