//
//  DateSorting.swift
//  ClientKit
//
//  Created by Rod Brown on 4/7/17.
//  Copyright © 2017 Rod Brown. All rights reserved.
//

import Foundation
import MPOLKit


public enum DateSorting: Int, Pickable {
    case newest
    case oldest
    
    static let allCases: [DateSorting] = [.newest, .oldest]
    
    
    // MARK: - Pickable
    
    public var title: String? {
        switch self {
        case .newest: return NSLocalizedString("Newest", comment: "")
        case .oldest: return NSLocalizedString("Oldest", comment: "")
        }
    }
    
    public var subtitle: String? {
        return nil
    }
    
    
    // MARK: - Comparison
    
    public func compare(_ date1: Date, _ date2: Date) -> Bool {
        switch self {
        case .newest: return date1 > date2
        case .oldest: return date1 < date2
        }
    }
}

