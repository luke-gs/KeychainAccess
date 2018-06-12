//
//  CADStateManagerType.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 16/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol defining a CAD state manager. A base implementation is provided in MPOLKit but customisations
/// or separate implementation should be implemented in ClientKit and set as shared on CADStateManager class below
public protocol CADStateManagerType {

    // MARK: - Properties

    /// The logged in officer details
    var officerDetails: CADEmployeeDetailsType? { get }

    /// The current patrol group
    var patrolGroup: String? { get set }

    /// The current sync mode
    var syncMode: CADSyncMode { get set }
    
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

    // MARK: - Manifest

    /// Fetch the officer capabilities
    func capabilityItems() -> [ManifestEntry]

    /// Fetch the book on equipment items
    func equipmentItems() -> [ManifestEntry]

    /// Fetch the patrol groups
    func patrolGroups() -> [ManifestEntry]

    /// Sync the latest manifest items, optionally matching the specified categories
    func syncManifestItems(categories: [String]?) -> Promise<Void>

    // MARK: - Sync

    /// Perform initial sync after login or launching app
    func syncInitial() -> Promise<Void>

    /// Sync the latest task summaries
    func syncDetails() -> Promise<Void>
    
    /// Return all resources linked to an incident
    func resourcesForIncident(incidentNumber: String) -> [CADResourceType]

    /// Return the current incident for a resource
    func incidentForResource(callsign: String) -> CADIncidentType?

    /// Return all officers linked to a resource
    func officersForResource(callsign: String) -> [CADOfficerType]

    // MARK: - Get Details

    /// Fetch details for a specific employee, or nil for current user
    func getEmployeeDetails(identifier: String?) -> Promise<CADEmployeeDetailsType>

    /// Fetch details for a specific incident
    func getIncidentDetails(identifier: String) -> Promise<CADIncidentDetailsType>

    /// Fetch details for a specific resource
    func getResourceDetails(identifier: String) -> Promise<CADResourceDetailsType>

    // MARK: - Book On

    /// Book on to a shift
    func bookOn(request: CADBookOnRequestType) -> Promise<Void>

    /// Terminate shift
    func bookOff() -> Promise<Void>

    /// Update the status of our callsign
    func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?, comments: String?, locationComments: String?) -> Promise<Void>
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

/// Enum for state manager errors
public enum CADStateManagerError: LocalizedError {
    case notLoggedIn
    case notBookedOn
    case itemNotFound

    public var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return NSLocalizedString("You must be logged on to perform this action.", comment: "")
        case .notBookedOn:
            return NSLocalizedString("You must be booked on to perform this action.", comment: "")
        case .itemNotFound:
            return NSLocalizedString("The requested item was not found.", comment: "")
        }
    }
}
/// Enum for different sync modes
public enum CADSyncMode: Equatable {
    case none
    case patrolGroup(patrolGroup: String)
    case map(boundingBox: MKMapView.BoundingBox)

    public static func ==(lhs: CADSyncMode, rhs: CADSyncMode) -> Bool {
        switch (lhs, rhs) {
        case (let .patrolGroup(patrolGroup1), let .patrolGroup(patrolGroup2)):
            return patrolGroup1 == patrolGroup2
        case (let .map(boundingBox1), let .map(boundingBox2)):
            return boundingBox1 == boundingBox2
        default:
            return false
        }
    }
}

