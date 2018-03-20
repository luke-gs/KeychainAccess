//
//  CADRecentlyUsedKey.swift
//  MPOLKit
//
//  Created by Kyle May on 8/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public struct CADRecentlyUsedKey: RawRepresentable, Equatable, Hashable {

    /// Recently used callsigns
    public static let callsigns = CADRecentlyUsedKey("callsigns")
    
    /// Recently used officers
    public static let officers = CADRecentlyUsedKey("officers")
    
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
