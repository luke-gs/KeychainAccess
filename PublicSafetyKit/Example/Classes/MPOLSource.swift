//
//  MPOLSource.swift
//  MPOLKitDemo
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


import Unbox

public enum MPOLSource: String, EntitySource, UnboxableEnum {
    case mpol = "mpol"
    case gnaf = "gnaf"

    public var serverSourceName: String {
        return self.rawValue
    }

    public var localizedBadgeTitle: String {
        switch self {
        case .mpol:
            return NSLocalizedString("MPOL", comment: "")
        case .gnaf:
            return NSLocalizedString("GNAF", comment: "")
        }
    }

    public var localizedBarTitle: String {
        switch self {
        case .mpol:
            return NSLocalizedString("MPOL", comment: "")
        case .gnaf:
            return NSLocalizedString("GNAF", comment: "")
        }
    }
}

