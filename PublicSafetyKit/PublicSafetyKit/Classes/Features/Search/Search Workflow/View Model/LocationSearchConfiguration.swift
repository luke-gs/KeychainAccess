//
//  LocationSearchConfiguration.swift
//  MPOLKit
//
//  Created by KGWH78 on 30/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MapKit

/// Location search configuration defines how often the typeahead search should occur.
public struct LocationTypeaheadConfiguration {
    
    /// The delay after the user enters the last character before making the request.
    public let throttle: TimeInterval
    
    /// The minimum characters required before making the request.
    public let minimumCharacters: Int
    
    public init(throttle: TimeInterval, minimumCharacters: Int) {
        self.throttle = throttle
        self.minimumCharacters = minimumCharacters
    }
    
    public static let `default` = LocationTypeaheadConfiguration(throttle: 0.5, minimumCharacters: 3)
}

/// Defines radius search configurations
public struct LocationTypeRadiusConfiguration {

    /// Radii in meters
    public let radiusOptions: [CLLocationDistance]

    public init(radiusOptions: [CLLocationDistance]) {
        self.radiusOptions = radiusOptions
    }

    public static let `default` = LocationTypeRadiusConfiguration(radiusOptions: [100, 500, 1000])

}
