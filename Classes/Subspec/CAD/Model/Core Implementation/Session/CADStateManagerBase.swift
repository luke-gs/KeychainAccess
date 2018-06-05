//
//  CADStateManagerBase.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Base implementation of CAD state manager. This class should contain common code
/// relevant to all clients or allow easy subclass overriding
open class CADStateManagerBase: CADStateManagerType {

    /// The API manager to use. This can be kit APIManager or custom class
    open var apiManager: CADAPIManagerType

    public init(apiManager: CADAPIManagerType) {
        self.apiManager = apiManager

        // Register concrete classes for protocols
        CADClientModelTypes.taskListSources = CADTaskListSourceCore.self
        CADClientModelTypes.officerDetails = CADOfficerCore.self
        CADClientModelTypes.equipmentDetails = CADEquipmentCore.self
        CADClientModelTypes.resourceStatus = CADResourceStatusCore.self
        CADClientModelTypes.resourceUnit = CADResourceUnitCore.self
        CADClientModelTypes.incidentGrade = CADIncidentGradeCore.self
        CADClientModelTypes.incidentStatus = CADIncidentStatusCore.self
        CADClientModelTypes.broadcastCategory = CADBroadcastCategoryCore.self
        CADClientModelTypes.patrolStatus = CADPatrolStatusCore.self
        CADClientModelTypes.alertLevel = CADAlertLevelCore.self
    }

    // MARK: - CADStateManagerType Properties

    /// The logged in officer details
    open var officerDetails: CADEmployeeDetailsResponseType?

    /// The patrol group
    open var patrolGroup: String? {
        didSet {
            didChangePatrolGroup(from: oldValue)
        }
    }

    /// The current sync mode
    open var syncMode: CADSyncMode = .none {
        didSet {
            didChangeSyncMode(from: oldValue)
        }
    }

    /// The last book on data
    open var lastBookOn: CADBookOnRequestType? {
        didSet {
            didChangeLastBookOn(from: oldValue)
        }
    }

    /// The last sync time
    open var lastSyncTime: Date?

    /// The last manifest sync time
    open var lastManifestSyncTime: Date?

    /// Incidents retrieved in last sync, in order
    open var incidents: [CADIncidentType] {
        return lastSync?.incidents ?? []
    }

    /// Resources retrieved in last sync, in order
    open var resources: [CADResourceType] {
        return lastSync?.resources ?? []
    }

    /// Officers retrieved in last sync, in order
    open var officers: [CADOfficerType] {
        return lastSync?.officers ?? []
    }

    /// Patrols retrieved in last sync, in order
    open var patrols: [CADPatrolType] {
        return lastSync?.patrols ?? []
    }

    /// Broadcasts retrieved in last sync, in order
    open var broadcasts: [CADBroadcastType] {
        return lastSync?.broadcasts ?? []
    }

    /// Incidents retrieved in last sync, keyed by incidentNumber
    open private(set) var incidentsById: [String: CADIncidentType] = [:]

    /// Resources retrieved in last sync, keyed by callsign
    open private(set) var resourcesById: [String: CADResourceType] = [:]

    /// Officers retrieved in last sync, keyed by payrollId
    open private(set) var officersById: [String: CADOfficerType] = [:]

    /// Patrols retrieved in last sync, keyed by patrolNumber
    open private(set) var patrolsById: [String: CADPatrolType] = [:]

    /// Broadcasts retrieved in last sync, keyed by callsign
    open private(set) var broadcastsById: [String: CADBroadcastType] = [:]

    /// The currently booked on resource
    open var currentResource: CADResourceType? {
        if let bookOn = lastBookOn {
            return resourcesById[bookOn.callsign]
        }
        return nil
    }

    /// The current incident for my callsign
    open var currentIncident: CADIncidentType? {
        if let bookOn = lastBookOn {
            return incidentForResource(callsign: bookOn.callsign)
        }
        return nil
    }

    // MARK: - Sync Properties

    /// Queue to get and set sync promise in thread safe manner
    open private(set) var syncQueue: DispatchQueue = DispatchQueue(label: "au.com.gridstone.CADStateManager")

    /// The currently pending sync promise
    open var pendingSync: Promise<Void>?

    /// The last sync data
    open var lastSync: CADSyncResponseType?

    /// The last synced bounding box
    open var lastSyncMapBoundingBox: MKMapView.BoundingBox? = nil

    // MARK: - Property changes

    open func didChangePatrolGroup(from oldValue: String?) {
        // By default set the sync mode based on whether we have a patrol group
        if let patrolGroup = self.patrolGroup {
            self.syncMode = .patrolGroup(patrolGroup: patrolGroup)
        } else {
            self.syncMode = .none
        }
    }

    open func didChangeSyncMode(from oldValue: CADSyncMode) {
        guard syncMode != oldValue else { return }

        // Force a sync unless just updating the map bounds
        let force: Bool
        switch (oldValue, syncMode) {
        case (.map(_), .map(_)):
            force = false
        default:
            force = true
        }

        // Sync if moving bounding box or switching back to patrol group
        _ = syncDetails(force: force)
    }

    open func didChangeLastBookOn(from oldValue: CADBookOnRequestType?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .CADBookOnChanged, object: self)
        }
    }


    // MARK: - Manifest

    /// Fetch the officer capabilities
    open func capabilityItems() -> [ManifestEntry] {
        return Manifest.shared.entries(for: .CapabilityCollection) ?? []
    }

    /// Fetch the book on equipment items
    open func equipmentItems() -> [ManifestEntry] {
        return Manifest.shared.entries(for: .EquipmentCollection) ?? []
    }

    /// Fetch the patrol groups
    open func patrolGroups() -> [ManifestEntry] {
        return Manifest.shared.entries(for: .PatrolGroupCollection) ?? []
    }

    /// Sync the latest manifest items, optionally matching the specified categories
    /// We use our own implementation of update here, so we can use custom API manager
    open func syncManifestItems(categories: [String]?) -> Promise<Void> {
        let checkedAtDate = Date()

        let manifestRequest: ManifestFetchRequest
        if let categories = categories {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   path: "manifest/manifest/categories",
                                                   parameters: ["categories": categories],
                                                   method: .post, updateType: .dateTime)
        } else {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   path: "manifest/manifest",
                                                   method: .get,
                                                   updateType: .dateTime)
        }
        return apiManager.fetchManifest(with: manifestRequest).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at:checkedAtDate)
        }.done { [unowned self] _ in
            self.lastManifestSyncTime = Date()
        }
    }

    // MARK: - Sync

    open func syncDetails() -> Promise<Void> {
        // Force a new sync be default
        return syncDetails(force: true)
    }

    /// Sync the latest task summaries
    open func syncDetails(force: Bool) -> Promise<Void> {
        // Dispatch to serial queue for checking/updating pendingSync promise
        return Promise<Void>().then(on: syncQueue, { _ -> Promise<Void> in

            // If already running a sync, chain off that sync
            if let pendingSync = self.pendingSync {
                self.pendingSync = pendingSync.then { [unowned self] in
                    return self.syncDetails()
                }
                return self.pendingSync!
            }

            // Sync based on the current sync mode
            switch self.syncMode {
            case .none:
                return Promise<Void>()
            case .patrolGroup(let patrolGroup):
                self.lastSyncMapBoundingBox = nil
                self.pendingSync = self.syncPatrolGroup(patrolGroup)
            case .map(let boundingBox):
                self.pendingSync = self.syncBoundingBox(boundingBox, force: force)
            }

            return self.pendingSync!.done(on: self.syncQueue, { [unowned self] in
                // No longer performing sync operation
                self.pendingSync = nil
            })
        })
    }

    /// Check whether a bounding box sync is needed
    open func requiresSyncForBoundingBox(_ boundingBox: MKMapView.BoundingBox) -> Bool {
        if let prevBoundingBox = lastSyncMapBoundingBox {
            // Check how far map has moved or been resized
            let prevSize = prevBoundingBox.northWestLocation.distance(from: prevBoundingBox.southEastLocation)
            let newSize = boundingBox.northWestLocation.distance(from: boundingBox.southEastLocation)
            let movedFactor = boundingBox.northWestLocation.distance(from: prevBoundingBox.northWestLocation) / prevSize
            let sizeFactor = abs(1 - (prevSize / newSize))
            if movedFactor < 0.05 && sizeFactor < 0.05 {
                // If less than 5% movement and size change since last sync, ignore
                return false
            }
        }
        return true
    }

    open func processSyncResponse(_ response: CADSyncResponseType) {
        self.lastSync = response
        self.lastSyncTime = Date()
        self.processSyncItems()
        NotificationCenter.default.post(name: .CADSyncChanged, object: self)
    }

    /// Process the last sync items for fast lookup
    open func processSyncItems() {
        if let syncDetails = lastSync {
            incidentsById.removeAll()
            for incident in syncDetails.incidents {
                incidentsById[incident.incidentNumber] = incident
            }
            patrolsById.removeAll()
            for patrol in syncDetails.patrols {
                patrolsById[patrol.identifier] = patrol
            }
            broadcastsById.removeAll()
            for broadcast in syncDetails.broadcasts {
                broadcastsById[broadcast.identifier] = broadcast
            }
            resourcesById.removeAll()
            for resource in syncDetails.resources {
                resourcesById[resource.callsign] = resource
            }
            officersById.removeAll()
            for officer in syncDetails.officers {
                officersById[officer.payrollId] = officer
            }

            // Make sure logged in officer is in cache too
            if let officerDetails = officerDetails {
                officersById[officerDetails.payrollId] = officerDetails
            }
        }
    }

    /// Return all resources linked to an incident
    open func resourcesForIncident(incidentNumber: String) -> [CADResourceType] {
        var resources: [CADResourceType] = []
        if let syncDetails = lastSync {
            for resource in syncDetails.resources {
                if resource.assignedIncidents.contains(incidentNumber) {
                    resources.append(resource)
                }
            }
        }
        return resources
    }

    /// Return the current incident for a resource
    open func incidentForResource(callsign: String) -> CADIncidentType? {
        if let resource = resourcesById[callsign], let incidentId = resource.currentIncident {
            return incidentsById[incidentId]
        }
        return nil
    }

    /// Return all officers linked to a resource
    open func officersForResource(callsign: String) -> [CADOfficerType] {
        var officers: [CADOfficerType] = []
        if let resource = resourcesById[callsign] {
            for payrollId in resource.payrollIds {
                if let officer = officersById[payrollId] {
                    officers.append(officer)
                }
            }
        }
        return officers
    }

    // MARK: - Subclass

    /// Perform initial sync after login or launching app
    open func syncInitial() -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Sync the patrol group
    open func syncPatrolGroup(_ patrolGroup: String) -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Sync a map bounding box
    open func syncBoundingBox(_ boundingBox: MKMapView.BoundingBox, force: Bool = false) -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Fetch the logged in officer's details
    open func fetchCurrentOfficerDetails() -> Promise<CADEmployeeDetailsResponseType> {
        MPLRequiresConcreteImplementation()
    }

    /// Book on to a shift
    open func bookOn(request: CADBookOnRequestType) -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Terminate shift
    open func bookOff() -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Update the status of our callsign
    open func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?, comments: String?, locationComments: String?) -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

}
