//
//  Source.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//
//

import Foundation
import Unbox

public enum Source: String, UnboxableEnum {
    case leap = "LEAP"
    
    public var localizedBadgeTitle: String {
        switch self {
        case .leap:
            return NSLocalizedString("LEAP", bundle: .mpolKit, comment: "")
        }
    }
    
    public var localizedBarTitle: String {
        switch self {
        case .leap:
            return NSLocalizedString("LEAP", bundle: .mpolKit, comment: "")
        }
    }
}
