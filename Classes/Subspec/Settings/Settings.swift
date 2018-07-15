//
//  Settings.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public enum SettingType {
    case `switch`(isOn: Bool, action: ((Bool)->()))
    case button((UIViewController)->())
}

public struct Setting {
    public var title: String
    public var subtitle: String?
    public var image: UIImage?
    public var type: SettingType

    public init(title: String, subtitle: String?, image: UIImage?, type: SettingType) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.type = type
    }
}

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

public struct SettingSection {
    public var type: SettingSectionType
    public var settings: [Setting]

    public init(type: SettingSectionType, settings: [Setting]) {
        self.type = type
        self.settings = settings
    }
}

public struct Settings: RawRepresentable {
    public let rawValue: Setting
    public init(rawValue: Setting) {
        self.rawValue = rawValue
    }
}
