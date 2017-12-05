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
    private static var shiftTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static var durationTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
    
    public var officerCountString: String? {
        return payrollIds.count > 0 ? "(\(payrollIds.count))" : nil
    }
    
    public var shiftStartString: String? {
        guard shiftStart != nil else { return nil }
        
        return SyncDetailsResource.shiftTimeFormatter.string(from: shiftStart)
    }
    
    public var shiftEndString: String? {
        guard shiftEnd != nil else { return nil }
        
        return SyncDetailsResource.shiftTimeFormatter.string(from: shiftEnd)
    }
    
    public var shiftDuration: String? {
        guard shiftStart != nil, shiftEnd != nil else { return nil }
        
        return SyncDetailsResource.durationTimeFormatter.string(from: shiftEnd.timeIntervalSince(shiftStart))
    }
}
