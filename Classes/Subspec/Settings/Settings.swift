//
//  Settings.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// Closure that is called when the Settings UI is about to update
public typealias SettingUIUpdateClosure = (()->())?

/// Closure to be called when the setting switch value is changed
///
/// 0: The new switch value
///
/// 1: The closure to execute if you need to update that cell UI after some action
public typealias SettingSwitchAction = ((Bool, SettingUIUpdateClosure)->())

/// Closure to be called when the setting button is tapped
///
/// 0: The presenting view controller
///
/// 1: The closure to execute if you need to update that cell UI after some action
public typealias SettingButtonAction = ((UIViewController, SettingUIUpdateClosure)->())

/// Closure that is called to set the value of the Setting switch
///
/// return: Bool whether the switch is on
public typealias SettingSwitchValue = (()->(Bool))

/// The type of UI control for the setting
///
/// - `switch`->: A switch control. `isOn` is a closure that runs to see whether the switch should be on. `action` is the closure to run when the switch is toggled.
/// - button->: A button type. `action` is the closure that runs when the button is tapped.
/// - plain: A boring ole type
public enum SettingControlType {
    case `switch`(isOn: SettingSwitchValue, action: SettingSwitchAction)
    case button(action: SettingButtonAction)
    case plain
}

/// A Setting to be used in SettingsViewController
public class Setting: Equatable {

    /// The title of the setting
    public var title: String

    /// A subtitle
    public var subtitle: String?

    /// An image
    public var image: UIImage?

    /// The setting type
    public var type: SettingControlType

    /// Closure called when cells will load/reload
    ///
    /// Update any settings titles/subtitles here
    public var onLoad: SettingUIUpdateClosure

    public init(title: String, subtitle: String?, image: UIImage?, type: SettingControlType, onLoad: SettingUIUpdateClosure = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.type = type
        self.onLoad = onLoad
    }

    public static func ==(lhs: Setting, rhs: Setting) -> Bool {
        return lhs.title == rhs.title
    }
}

/// The setting section type
///
/// - plain: A normal section in the body of the screen. `title` is the title of the section.
/// - pinned: A section that is pinned to the bottom of the screen.
public enum SettingSectionType: Equatable {
    case plain(title: String)
    case pinned

    public static func ==(lhs: SettingSectionType, rhs: SettingSectionType) -> Bool {
        switch (lhs, rhs) {
        case (.plain, .pinned), (.pinned, .plain):
            return false
        case (.plain(let lhsTitle), .plain(let rhsTitle)):
            return lhsTitle == rhsTitle
        case (.pinned, .pinned):
            return true
        }
    }
}

/// A setting section to be used in SettingsViewController
public struct SettingSection {

    /// The type of section
    public var type: SettingSectionType

    /// The settings in this section
    public var settings: [Setting]

    public init(type: SettingSectionType, settings: [Setting]) {
        self.type = type
        self.settings = settings
    }
}

/// An extensible setting object
public struct Settings: RawRepresentable {
    public let rawValue: Setting
    public init(rawValue: Setting) {
        self.rawValue = rawValue
    }
}
