//
//  SyncDetailsIncident+Computed.swift
//  MPOLKit
//
//  Created by Kyle May on 1/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

/// Adds computed properties to `SyncDetailsIncident`
extension SyncDetailsIncident {
    
    public enum Status: String, Codable {
        case resourced = "Resourced"
        case unresourced = "Unresourced"
        case current = "Current Incident"
        case assigned = "Assigned"
    }
    
    // MARK: - Computed
    
    open var status: Status {
        if let resourceId = CADStateManager.shared.lastBookOn?.callsign,
            let resource = CADStateManager.shared.resourcesById[resourceId]
        {
            if resource.incidentNumber == incidentNumber {
                return .current
            } else {
                return .assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber).count > 0 {
            return .resourced
        } else {
            return .unresourced
        }
    }
    
    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
    
    open var resourceCount: Int {
        return CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber).count
    }
    
    open var resourceCountString: String? {
        return resourceCount > 0 ? "(\(resourceCount))" : nil
    }
}
