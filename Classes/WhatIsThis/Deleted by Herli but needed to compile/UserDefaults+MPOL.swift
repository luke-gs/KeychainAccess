//
//  UserDefaults+MPOL.swift
//  MPOLKit
//
//  Created by Rod Brown on 9/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// The MPOL User Defaults
    public static let mpol = UserDefaults(suiteName: "group.com.gridstone.mpol")! // TODO: Need to get the suite name from the client.
    
}
