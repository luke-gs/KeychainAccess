//
//  UserDefaults+MPOL.swift
//  Pods
//
//  Created by Rod Brown on 9/5/17.
//
//

import Foundation
import CoreFoundation

// TODO: This needs a refactor. Quick and dirty for release.

extension UserDefaults {
    
    /// The MPOL User Defaults
    public static let mpol = UserDefaults(suiteName: "group.com.gridstone.mpol")! // TODO: Need to get the suite name from the client.
    
    private static let mpolDefaultsChangeNotificationBaseName = "group.com.gridstone.mpol.defaultsDidChange."
    
    public class func mpolDefaultsDidChangeNotificationName(forKey key: String) -> CFString {
        return (mpolDefaultsChangeNotificationBaseName + key) as CFString
    }
    
    public class func postMPOLDefaultsDidChangeNotification(forKey key: String) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             CFNotificationName(rawValue: mpolDefaultsDidChangeNotificationName(forKey: key)),
                                             nil, nil, true)
        
    }
    
}
