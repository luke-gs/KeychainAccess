//
//  SyncDetailsResource+Computed.swift
//  MPOLKit
//
//  Created by Kyle May on 1/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

/// Adds computed properties to `SyncDetailsResource`
extension SyncDetailsResource {
    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
    
    open var officerCountString: String? {
        return payrollIds.count > 0 ? "(\(payrollIds.count))" : nil
    }
}
