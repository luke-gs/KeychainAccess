//
//  DefaultFilterRules.swift
//  MPOL
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PublicSafetyKit

public struct DefaultFilterRules {

    /// Rules that will match `login` and `refresh` as last path component of a URL.
    static public let authenticationFilterRules = PatternsMatchRules(patterns: ["https://*/refresh", "https://*/login"])
}
