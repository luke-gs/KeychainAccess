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
    var title: String
    var subtitle: String?
    var image: UIImage?
    var type: SettingType
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
        default:
            return false
        }
    }
}

public struct SettingSection {
    var type: SettingSectionType
    var settings: [Setting]
}

public struct Settings: RawRepresentable {
    public let rawValue: Setting

    public init(rawValue: Setting) {
        self.rawValue = rawValue
    }
}
