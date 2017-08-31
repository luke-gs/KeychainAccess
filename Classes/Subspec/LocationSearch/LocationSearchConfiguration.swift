//
//  LocationSearchConfiguration.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// Location search configuration defines how often the typeahead search should occur.
public struct LocationSearchConfiguration {
    
    /// The delay after the user enters the last character before making the request.
    public let throttle: TimeInterval
    
    /// The minimum characters required before making the request.
    public let minimumCharacters: Int
    
    public init(throttle: TimeInterval, minimumCharacters: Int) {
        self.throttle = throttle
        self.minimumCharacters = minimumCharacters
    }
    
    public static let `default` = LocationSearchConfiguration(throttle: 0.5, minimumCharacters: 3)
}

