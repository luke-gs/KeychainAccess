//
//  BiometricIDSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import LocalAuthentication

public extension Settings {

    public static func appropriateBiometric() -> Setting? {
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if #available(iOS 11.0.1, *) {
                if context.biometryType == .faceID {
                    return Settings.faceBiometric
                }
            }
            return Settings.fingerBiometric
        }
        return nil
    }

    /// Setting for biometric identification handling
    public static let fingerBiometric = Setting(title: NSLocalizedString("Touch ID", comment: ""),
                                                subtitle: NSLocalizedString("Touch ID will be offered on next login if enabled.", comment: ""),
                                                image: AssetManager.shared.image(forKey: .touchId),
                                                type: .switch(isOn: isOn,
                                                              action: handleBiometrics))

    public static let faceBiometric = Setting(title: NSLocalizedString("Face ID", comment: ""),
                                              subtitle: NSLocalizedString("Face ID will be offered on next login if enabled.", comment: ""),
                                              image: AssetManager.shared.image(forKey: .faceId),
                                              type: .switch(isOn: isOn,
                                                            action: handleBiometrics))

    private static func handleBiometrics(_ isOn: Bool, completion: SettingUIUpdateClosure) {

        let currentValue = Settings.isOn()
        let newValue = isOn

        if currentValue == newValue {
            return
        }

        if let user = UserSession.current.user,
            var handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain),
            let userSessionUsername = user.username,
            handler.username == userSessionUsername {
            if currentValue == false && newValue == true {
                // Previously off, and now they want to turn this on.
                // Clear the settings so the user will be asked when they want to login next.
                handler.clear()
                // Workaround, also needs to set it to the current user session to synchronise the data.
                user.setAppSettingValue(UseBiometric.unknown.rawValue as AnyObject, forKey: .useBiometric)
            } else if currentValue == true && newValue == false {
                // Previously on, and now they want to turn this off.
                // Set it to asked so the user won't be prompted to use it.
                handler.useBiometric = .asked
                user.setAppSettingValue(handler.useBiometric.rawValue as AnyObject, forKey: .useBiometric)
            }
        }

    }

    private static func isOn() -> Bool {
        if let useBiometricValue = UserSession.current.user?.appSettingValue(forKey: .useBiometric) as? String,
            let useBiometric = UseBiometric(rawValue: useBiometricValue) {
            // If it's agreed the it's On
            // If it's unknown, that means it'll be asked on next login. Consider that as it's On.
            return useBiometric == .agreed || useBiometric == .unknown
        }
        return false
    }
}
