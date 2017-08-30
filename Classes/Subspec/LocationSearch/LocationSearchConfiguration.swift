//
//  LocationSearchConfiguration.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public struct LocationSearchConfiguration {
    public var throttle: TimeInterval
    public var minimumCharacters: Int
    
    public init(throttle: TimeInterval, minimumCharacters: Int) {
        self.throttle = throttle
        self.minimumCharacters = minimumCharacters
    }
    
    public static let `default` = LocationSearchConfiguration(throttle: 0.5, minimumCharacters: 3)
}

