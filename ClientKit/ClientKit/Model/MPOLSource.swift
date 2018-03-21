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
    case pscore = "pscore"
    case gnaf = "gnaf"
    case fnc = "fnc"

    public var serverSourceName: String {
        return self.rawValue
    }

    public var localizedBadgeTitle: String {
        switch self {
        case .pscore, .gnaf:
            return NSLocalizedString("PSCORE", bundle: .mpolKit, comment: "")
        case .fnc:
            return NSLocalizedString("FNC", bundle: .mpolKit, comment: "")
        }
    }

    public var localizedBarTitle: String {
        switch self {
        case .pscore, .gnaf:
            return NSLocalizedString("PSCORE", bundle: .mpolKit, comment: "")
        case .fnc:
            return NSLocalizedString("FNC", bundle: .mpolKit, comment: "")
        }
    }
}
