//
//  BiometricIDSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public extension Settings {
    public static let biometrics = Setting(title: "Touch/FaceID",
                                           subtitle: nil,
                                           image: AssetManager.shared.image(forKey: .touchId),
                                           type: .switch(isOn: isOn,
                                                         action: handleBiometrics))

    private static func handleBiometrics(_ isOn: Bool) {
        if let user = UserSession.current.user {
            var handler = BiometricUserHandler.currentUser(in: SharedKeychainCapability.defaultKeychain)
            handler?.clear()
            user.setAppSettingValue(nil, forKey: .useBiometric)
        }
    }

    private static func isOn() -> Bool {
        if let useBiometricValue = UserSession.current.user?.appSettingValue(forKey: .useBiometric) as? String,
            let useBiometric = UseBiometric(rawValue: useBiometricValue)
        {
            return useBiometric == .agreed
        }
        return false
    }
}
