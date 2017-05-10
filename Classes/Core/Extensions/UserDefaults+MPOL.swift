//
//  UserDefaults+MPOL.swift
//  Pods
//
//  Created by Rod Brown on 9/5/17.
//
//

import Foundation

extension UserDefaults {
    
    /// The MPOL User Defaults
    public static let mpol = UserDefaults(suiteName: "group.com.gridstone.mpol")! // TODO: Need to get the suite name from the client.
    
}
