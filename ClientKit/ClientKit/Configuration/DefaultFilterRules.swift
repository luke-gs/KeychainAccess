//
//  DefaultFilterRules.swift
//  ClientKit
//
//  Created by Herli Halim on 11/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public struct DefaultFilterRules {

    static private let excludeAuthentication: Set<String> = ["login", "refresh"]

    /// Rules that will match `login` and `refresh` as last path component of a URL.
    static public let authenticationFilterRules = URLRulesMatch { url -> Bool in
        return excludeAuthentication.contains(url.lastPathComponent)
    }

}
