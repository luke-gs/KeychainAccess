//
//  CADRecentlyUsedKey.swift
//  MPOLKit
//
//  Created by Kyle May on 8/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

extension UserPreferenceKey {
    /// Recently used callsigns
    public static let recentCallsigns = UserPreferenceKey("recentCallsigns")
    
    /// Recently used officers
    public static let recentCADOfficers = UserPreferenceKey("recentCADOfficers")
}

public class CADRecentlyUsedKey: ExtensibleKey<String> {

    /// Recently used callsigns
    public static let callsigns = CADRecentlyUsedKey("callsigns")
    
    /// Recently used officers
    public static let officers = CADRecentlyUsedKey("officers")

}
