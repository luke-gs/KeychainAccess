//
//  AlertLevel.swift
//  Pods
//
//  Created by Rod Brown on 20/3/17.
//
//

import UIKit

public enum AlertLevel: Int {
    case low    = 1
    case medium = 2
    case high   = 3
    
    public var color: UIColor {
        switch self {
        case .low:    return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .medium: return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
        case .high:   return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        }
    }
    
    public var localizedIndicatorTitle: String {
        switch self {
        case .low:    return NSLocalizedString("LOW",  comment: "Alert Level indicator title")
        case .medium: return NSLocalizedString("MED",  comment: "Alert Level indicator title")
        case .high:   return NSLocalizedString("HIGH", comment: "Alert Level indicator title")
        }
    }
}
