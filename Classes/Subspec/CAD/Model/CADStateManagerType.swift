//
//  CADStateManagerType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol defining a CAD state manager. To be implemented in ClientKit
public protocol CADStateManagerType {

}

/// Concrete class to provide static access to current state manager
open class CADStateManager {

    /// The singleton state manager
    public static var shared: CADStateManagerType! {
        get {
            guard let manager = _sharedManager else {
                fatalError("`CADStateManager.shared` needs to be assigned before use.")
            }
            return manager
        }
        set {
            _sharedManager = newValue
        }
    }

    private static var _sharedManager: CADStateManagerType?
}

// Extension for custom notifications
public extension NSNotification.Name {
    /// Notification posted when book on changes
    static let CADBookOnChanged = NSNotification.Name(rawValue: "CAD_BookOnChanged")

    /// Notification posted when callsign changes
    static let CADCallsignChanged = NSNotification.Name(rawValue: "CAD_CallsignChanged")

    /// Notification posted when sync changes
    static let CADSyncChanged = NSNotification.Name(rawValue: "CAD_SyncChanged")
}

// Extension for custom manifest categories
public extension ManifestCollection {
    static let EquipmentCollection = ManifestCollection(rawValue: "equipment")
    static let PatrolGroupCollection = ManifestCollection(rawValue: "patrolgroup")
}

