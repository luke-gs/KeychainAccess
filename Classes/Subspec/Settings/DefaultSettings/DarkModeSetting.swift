//
//  DarkModeSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public extension Settings {

    /// Setting for dark mode handling
    public static let darkMode = Setting(title: "Dark Mode",
                                         subtitle: "Triple tap on navigation bar to toggle night mode",
                                         image: AssetManager.shared.image(forKey: .nightMode),
                                         type: .switch(isOn: isOn,
                                                       action: { isOn, completion in
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            ThemeManager.shared.currentInterfaceStyle = isOn ? .dark : .light
                                                        }
                                         }))
    private static func isOn() -> Bool {
        return ThemeManager.shared.currentInterfaceStyle == .dark
    }
}
