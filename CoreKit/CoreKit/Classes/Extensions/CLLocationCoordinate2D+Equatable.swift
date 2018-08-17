//
//  CLLocationCoordinate2D+Equatable.swift
//  CoreKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MapKit

// Disabled due to re-definition in Cluster pod :(
//extension CLLocationCoordinate2D: Equatable { }

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
