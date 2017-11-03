//
//  LocalUserSettings.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 3/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Locally stored user settings, stored per application
open class LocalUserSettings: NSObject, NSSecureCoding {

    /// The last terms and conditions version that was accepted
    public var termsAndConditionsVersionAccepted: String?

    /// The last what's new screen version that was shown
    public var whatsNewShownVersion: String?

    // MARK: - isEqual

    override open func isEqual(_ object: Any?) -> Bool {
        guard let compared = object as? LocalUserSettings else {
            return false
        }
        return termsAndConditionsVersionAccepted == compared.termsAndConditionsVersionAccepted &&
            whatsNewShownVersion == compared.whatsNewShownVersion
    }

    // MARK: - NSSecureCoding

    private enum CodingKeys: String {
        case termsAndConditionsVersionAccepted = "termsAndConditionsVersionAccepted"
        case whatsNewShownVersion = "whatsNewShownVersion"
    }

    open static var supportsSecureCoding: Bool {
        return true
    }

    public required init?(coder aDecoder: NSCoder) {
        self.termsAndConditionsVersionAccepted = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.termsAndConditionsVersionAccepted.rawValue) as String?
        self.whatsNewShownVersion = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.whatsNewShownVersion.rawValue) as String?
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(termsAndConditionsVersionAccepted, forKey: CodingKeys.termsAndConditionsVersionAccepted.rawValue)
        aCoder.encode(whatsNewShownVersion, forKey: CodingKeys.whatsNewShownVersion.rawValue)
    }
}
