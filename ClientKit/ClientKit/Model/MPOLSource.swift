//
//  MPOLSource.swift
//  MPOLKit
//
//  Created by Herli Halim on 13/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

public enum MPOLSource: String, EntitySource, UnboxableEnum {
    case pscore = "ds1"
    case nat = "ds2"
    case rda = "ds3"
    case gnaf = "gnaf"

    public var serverSourceName: String {
        return self.rawValue
    }

    public var localizedBadgeTitle: String {
        switch self {
        case .pscore, .gnaf:
            return NSLocalizedString("Local Law Enforcement", comment: "")
        case .nat:
            return NSLocalizedString("National Database", comment: "")
        case .rda:
            return NSLocalizedString("Road Authority", comment: "")
        }
    }

    public var localizedBarTitle: String {
        switch self {
        case .pscore, .gnaf:
            return NSLocalizedString("LOC", comment: "")
        case .nat:
            return NSLocalizedString("NAT", comment: "")
        case .rda:
            return NSLocalizedString("RDA", comment: "")
        }
    }
}

extension MPOLSource: UnboxableKey {
    
    public static func transform(unboxedKey: String) -> MPOLSource? {
        return MPOLSource(rawValue: unboxedKey)
    }

}
