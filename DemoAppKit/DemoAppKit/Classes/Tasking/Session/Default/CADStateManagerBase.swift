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
    }

    // MARK: - CADStateManagerType Properties

    /// The logged in officer details
    open var officerDetails: CADOfficerType?

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
    open var incidentsById: [String: CADIncidentType] = [:]

    /// Resources retrieved in last sync, keyed by callsign
    open var resourcesById: [String: CADResourceType] = [:]

    /// Officers retrieved in last sync, keyed by payrollId
    open var officersById: [String: CADOfficerType] = [:]

    /// Patrols retrieved in last sync, keyed by patrolNumber
    open var patrolsById: [String: CADPatrolType] = [:]

    /// Broadcasts retrieved in last sync, keyed by callsign
    open var broadcastsById: [String: CADBroadcastType] = [:]

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

    /// Whether there is currently a queued sync operation
    open var isQueuedSync: Bool = false

    /// The last sync data
    open var lastSync: CADSyncResponseType?

    /// The last synced bounding box
    open var lastSyncMapBoundingBox: MKMapRect.BoundingBox?

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
        case (.map, .map):
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

    /// Fetch manifest entries
    open func manifestEntries(for collection: ManifestCollection, activeOnly: Bool, sortedBy: [NSSortDescriptor]?) -> [ManifestEntry] {
        // Just forward this to standard manifest by default. Clients can override if needed
        return Manifest.shared.entries(for: collection, activeOnly: activeOnly, sortedBy: sortedBy) ?? []
    }

    /// TODO: Remove this function and use the ClientKit's version once CAD is separated into Kit/App
    ///
    /// Sync the latest manifest items, optionally matching the specified categories
    /// We use our own implementation of update here, so we can use custom API manager
    open func syncManifestItems(collections: [ManifestCollection]?) -> Promise<Void> {
        let checkedAtDate = Date()

        let manifestRequest: ManifestFetchRequest
        if let collections = collections {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   fetchType: .partial(collections: collections))
        } else {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   fetchType: .full)
        }
        return apiManager.fetchManifest(with: manifestRequest).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at: checkedAtDate)
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
        return Promise<Void>().then(on: syncQueue, { [unowned self] _ -> Promise<Void> in
            // Check if already syncing
            if let pendingSync = self.pendingSync {
                if self.isQueuedSync {
                    // If there is already a queued sync, no need to chain another new sync
                    return pendingSync
                } else {
                    // If already running a sync, chain a new queued sync
                    self.isQueuedSync = true
                    self.pendingSync = pendingSync.then(on: self.syncQueue, { [unowned self] _ -> Promise<Void> in
                        self.isQueuedSync = false
                        return self.syncDetails()
                    })
                    return self.pendingSync!
                }
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
            }).recover(on: self.syncQueue, { error in
                self.pendingSync = nil
                throw error
            })
        })
    }

    /// Check whether a bounding box sync is needed
    open func requiresSyncForBoundingBox(_ boundingBox: MKMapRect.BoundingBox) -> Bool {
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
        self.processSyncItems()
        self.lastSyncTime = Date()
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
                officersById[officer.id] = officer
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
            for id in resource.officerIds {
                if let officer = officersById[id] {
                    officers.append(officer)
                }
            }
        }
        return officers
    }

    /// Clears all session data properties
    open func clearSession() {
        self.officerDetails = nil
        self.patrolGroup = nil
        self.lastBookOn = nil
        self.lastSync = nil
        self.lastSyncTime = nil
        self.pendingSync = nil
        self.isQueuedSync = false
        self.lastSyncMapBoundingBox = nil

        self.syncMode = .none

        self.incidentsById.removeAll()
        self.resourcesById.removeAll()
        self.officersById.removeAll()
        self.patrolsById.removeAll()
        self.broadcastsById.removeAll()
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
    open func syncBoundingBox(_ boundingBox: MKMapRect.BoundingBox, force: Bool = false) -> Promise<Void> {
        MPLRequiresConcreteImplementation()
    }

    /// Fetch details for a specific incident
    open func getIncidentDetails(identifier: String) -> Promise<CADIncidentDetailsType> {
        MPLRequiresConcreteImplementation()
    }

    /// Fetch details for a specific resource
    open func getResourceDetails(identifier: String) -> Promise<CADResourceDetailsType> {
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
