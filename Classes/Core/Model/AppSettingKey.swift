//
//  AppSettingKey.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Extensible 'enum' for local app setting keys
/// Implemented the same way swift imports NS_TYPED_EXTENSIBLE_ENUMs from obj-c
public struct AppSettingKey: RawRepresentable, Equatable, Hashable {

    /// The last terms and conditions version that was accepted
    public static let termsAndConditionsVersionAccepted = AppSettingKey("termsAndConditionsVersionAccepted")

    /// The last what's new screen version that was shown
    public static let whatsNewShownVersion = AppSettingKey("whatsNewShownVersion")


    // MARK: - Internal
    public typealias RawValue = String

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }
}
