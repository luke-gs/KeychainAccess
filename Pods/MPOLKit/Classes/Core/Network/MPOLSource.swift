//
//  MPOLSource.swift
//  Pods
//
//  Created by Herli Halim on 13/6/17.
//
//

import Foundation
import Unbox

public enum MPOLSource: String, EntitySource, UnboxableEnum {
    case mpol = "MPOL"
    
    public var serverSourceName: String {
        return self.rawValue
    }
    
    public var localizedBadgeTitle: String {
        switch self {
        case .mpol:
            return NSLocalizedString("MPOL", bundle: .mpolKit, comment: "")
        }
    }
    
    public var localizedBarTitle: String {
        switch self {
        case .mpol:
            return NSLocalizedString("MPOL", bundle: .mpolKit, comment: "")
        }
    }
}
