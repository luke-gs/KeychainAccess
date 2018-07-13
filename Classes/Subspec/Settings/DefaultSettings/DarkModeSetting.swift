//
//  DarkModeSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

extension Settings {
    static let darkMode = Setting(title: "Dark Mode",
                                  subtitle: nil,
                                  image: AssetManager.shared.image(forKey: .nightMode),
                                  type: .switch(isOn: ThemeManager.shared.currentInterfaceStyle == .dark,
                                                action: { isOn in
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        ThemeManager.shared.currentInterfaceStyle = isOn ? .dark : .light
                                                    }
                                  }))
}
