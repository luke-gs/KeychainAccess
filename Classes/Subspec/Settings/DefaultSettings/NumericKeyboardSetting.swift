//
//  NumericKeyboardSetting.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public extension Settings {

    /// Setting for numeric keyboard handling
    public static let numericKeyboard = Setting(title: "Numeric Keyboard",
                                                subtitle: nil,
                                                image: AssetManager.shared.image(forKey: .keyboard),
                                                type: .switch(isOn: isOn,
                                                              action: { isOn in
                                                                KeyboardInputManager.shared.isNumberBarEnabled = isOn
                                                }))
    private static func isOn() -> Bool {
        return KeyboardInputManager.shared.isNumberBarEnabled
    }
}
