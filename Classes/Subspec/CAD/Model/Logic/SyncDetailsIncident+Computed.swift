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
            if resource.currentIncident == number {
                return .current
            } else {
                return .assigned
            }
        } else if CADStateManager.shared.resourcesForIncident(incidentNumber: number).count > 0 {
            return .resourced
        } else {
            return .unresourced
        }
    }
    
    open var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }
    
    open var resourceCount: Int {
        return CADStateManager.shared.resourcesForIncident(incidentNumber: number).count
    }
    
    open var resourceCountString: String {
        return resourceCount > 0 ? "(\(resourceCount))" : ""
    }
    
    open var createdAtString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        
        return formatter.string(from: createdAt)
    }
    
    open var lastUpdatedString: String {
        let timeInterval = Int(abs(lastUpdated.timeIntervalSinceNow))
        // TODO: Convert to mins hours etc.
        return "\(timeInterval) seconds ago"
    }
}

extension SyncDetailsIncidentPerson {
    open var initials: String {
        return "\(firstName.prefix(1))\(lastName.prefix(1))"
    }
    
    open var fullName: String {
        let lastFirst = [lastName, firstName].removeNils().joined(separator: ", ")
        let middle = middleNames != nil ? "\(middleNames.prefix(1))." : ""
        
        return "\(lastFirst) \(middle)"
    }
}
