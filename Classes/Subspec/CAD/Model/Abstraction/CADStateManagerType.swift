//
//  CADStateManagerType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

public enum CADStateManagerError: Error {
    case notLoggedIn
}

/// Protocol defining a CAD state manager. To be implemented in ClientKit and set as shared on CADStateManager class below
public protocol CADStateManagerType {
    
    // MARK: - Synced State

    /// The logged in officer details
    var officerDetails: CADEmployeeDetailsResponseType? { get }

    /// The current patrol group
    var patrolGroup: String? { get set }

    /// The last book on data
    var lastBookOn: CADBookOnRequestType? { get }

    /// The last sync time
    var lastSyncTime: Date? { get }

    /// The last manifest sync time
    var lastManifestSyncTime: Date? { get }

    /// Incidents retrieved in last sync, in order
    var incidents: [CADIncidentType] { get }

    /// Incidents retrieved in last sync, keyed by incidentNumber
    var incidentsById: [String: CADIncidentType] { get }

    /// Resources retrieved in last sync, in order
    var resources: [CADResourceType] { get }

    /// Resources retrieved in last sync, keyed by callsign
    var resourcesById: [String: CADResourceType] { get }

    /// Officers retrieved in last sync, in order
    var officers: [CADOfficerType] { get }

    /// Officers retrieved in last sync, keyed by payrollId
    var officersById: [String: CADOfficerType] { get }

    /// Patrols retrieved in last sync, in order
    var patrols: [CADPatrolType] { get }

    /// Patrols retrieved in last sync, keyed by patrolNumber
    var patrolsById: [String: CADPatrolType] { get }

    /// Broadcasts retrieved in last sync, in order
    var broadcasts: [CADBroadcastType] { get }

    /// Broadcasts retrieved in last sync, keyed by callsign
    var broadcastsById: [String: CADBroadcastType] { get }

    /// The currently booked on resource
    var currentResource: CADResourceType? { get }

    /// The current incident for my callsign
    var currentIncident: CADIncidentType? { get }

    // MARK: - Officer

    /// Fetch the logged in officer's details
    func fetchCurrentOfficerDetails() -> Promise<CADEmployeeDetailsResponseType>

    // MARK: - Shift

    /// Book on to a shift
    func bookOn(request: CADBookOnRequestType) -> Promise<Void>

    /// Terminate shift
    func bookOff() -> Promise<Void>

    /// Update the status of our callsign
    func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?, comments: String?, locationComments: String?) -> Promise<Void>

    // MARK: - Manifest

    /// Fetch the officer capabilities
    func capabilityItems() -> [ManifestEntry]

    /// Fetch the book on equipment items
    func equipmentItems() -> [ManifestEntry]

    /// Fetch the patrol groups
    func patrolGroups() -> [ManifestEntry]

    /// Sync the latest manifest items
    func syncManifestItems() -> Promise<Void>
    
    /// Sync the latest manifest items matching the specified categories
    func syncManifestItems(categories: [String]) -> Promise<Void>

    // MARK: - Sync

    /// Sync the latest task summaries
    func syncDetails() -> Promise<Void>

    /// Perform initial sync after login or launching app
    func syncInitial() -> Promise<Void>

    /// Return all resources linked to an incident
    func resourcesForIncident(incidentNumber: String) -> [CADResourceType]

    /// Return the current incident for a resource
    func incidentForResource(callsign: String) -> CADIncidentType?

    /// Return all officers linked to a resource
    func officersForResource(callsign: String) -> [CADOfficerType]

    // MARK: - Notifications

    /// Adds or removes scheduled local notifications
    func updateScheduledNotifications()
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
    static let CapabilityCollection = ManifestCollection(rawValue: "Capability")
    static let EquipmentCollection = ManifestCollection(rawValue: "Equipment")
    static let PatrolGroupCollection = ManifestCollection(rawValue: "PatrolGroup")
}

/// Extendable class for defining CAD specific local notifications
open class CADLocalNotifications {
    public static let shiftEnding = "CADShiftEndingNotification"
}
