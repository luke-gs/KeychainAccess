//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// PSCore implementation of CAD state manager
open class CADStateManagerCore: CADStateManagerType {

    /// Enum for state manager errors
    public enum StateManagerError: Error {
        case notBookedOn
    }

    /// The API manager to use, by default system one
    open static var apiManager: CADAPIManagerType!

    public init() {
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

    // MARK: - Synced State

    /// The logged in officer details
    open var officerDetails: CADEmployeeDetailsResponseType?
    
    /// The patrol group
    // TODO: Find out when to set/clear this value and where it's coming from
    open var patrolGroup: String? = "Collingwood"

    /// Whether the map is set to show results outside the patrol group
    open var showsResultsOutsidePatrolGroup: Bool = false
    
    /// Current bounding box of the main CAD map
    open var mapBoundingBox: MKMapView.BoundingBox? = nil
    
    /// The last book on data
    open private(set) var lastBookOn: CADBookOnRequestType? {
        didSet {
            updateScheduledNotifications()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .CADBookOnChanged, object: self)
            }
        }
    }

    /// The last sync data
    open private(set) var lastSync: CADSyncResponseCore?

    /// The last sync time
    open private(set) var lastSyncTime: Date?
    
    /// The last manifest sync time
    open private(set) var lastManifestSyncTime: Date?

    /// Incidents retrieved in last sync, in order
    public var incidents: [CADIncidentType] {
        return lastSync?.incidents ?? []
    }

    /// Resources retrieved in last sync, in order
    public var resources: [CADResourceType] {
        return lastSync?.resources ?? []
    }

    /// Officers retrieved in last sync, in order
    public var officers: [CADOfficerType] {
        return lastSync?.officers ?? []
    }

    /// Patrols retrieved in last sync, in order
    public var patrols: [CADPatrolType] {
        return lastSync?.patrols ?? []
    }

    /// Broadcasts retrieved in last sync, in order
    public var broadcasts: [CADBroadcastType] {
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
        if let bookOn = CADStateManager.shared.lastBookOn {
            return CADStateManager.shared.resourcesById[bookOn.callsign]
        }
        return nil
    }

    /// The current incident for my callsign
    open var currentIncident: CADIncidentType? {
        if let bookOn = CADStateManager.shared.lastBookOn {
            return CADStateManager.shared.incidentForResource(callsign: bookOn.callsign)
        }
        return nil
    }

    // MARK: - Officer

    open func fetchCurrentOfficerDetails() -> Promise<CADEmployeeDetailsResponseType> {
        if let username = UserSession.current.user?.username {
            let request = CADEmployeeDetailsRequestCore(employeeNumber: username)
            let promise: Promise<CADEmployeeDetailsResponseCore> = CADStateManagerCore.apiManager.cadEmployeeDetails(with: request, pathTemplate: nil)
            return promise.map { [unowned self] details in
                self.officerDetails = details
                return details
            }
        }
        
        return Promise(error: CADStateManagerError.notLoggedIn)
    }

    /// Clears current incident and sets status to on air
    open func finaliseIncident() {
        currentResource?.status = CADResourceStatusCore.onAir
        clearIncident()
    }
    
    /// Un-assigns the current incident for the booked on resource
    open func clearIncident() {
        if let incident = currentIncident, let resource = currentResource {

            // Remove incident from being assigned to resource
            var assignedIncidents = resource.assignedIncidents
            if let index = assignedIncidents.index(of: incident.identifier) {
                assignedIncidents.remove(at: index)
                resource.assignedIncidents = assignedIncidents
            }
            resource.currentIncident = nil
        }
    }

    // MARK: - Shift

    /// Book on to a shift
    open func bookOn(request: CADBookOnRequestType) -> Promise<Void> {

        // Perform book on to server
        return CADStateManagerCore.apiManager.cadBookOn(with: request).done { [unowned self] in

            // Update book on and notify observers
            self.lastBookOn = request

            // Store recent IDs
            UserSession.current.addRecentId(request.callsign, forKey: CADRecentlyUsedKey.callsigns.rawValue)
            UserSession.current.addRecentIds(request.employees.map { $0.payrollId }, forKey: CADRecentlyUsedKey.officers.rawValue)

            // TODO: remove this when we have a real CAD system
            if let lastBookOn = self.lastBookOn, let resource = self.currentResource {
                let officerIds = lastBookOn.employees.map({ return $0.payrollId })

                // Update callsign for new officer list
                resource.payrollIds = officerIds

                // Update call sign for new equipment list
                resource.equipment = lastBookOn.equipment

                // Set state if callsign was off duty
                if resource.status == CADResourceStatusCore.offDuty {
                    resource.status = CADResourceStatusCore.onAir
                }

                // Check if logged in officer is no longer in callsign
                if let officerDetails = self.officerDetails, !officerIds.contains(officerDetails.payrollId) {
                    // Treat like being booked off, using async to trigger didSet again
                    DispatchQueue.main.async {
                        self.lastBookOn = nil
                    }
                }
            }
        }
    }

    /// Terminate shift
    open func bookOff() -> Promise<Void> {
        guard let lastBookOn = lastBookOn else { return Promise<Void>(error: StateManagerError.notBookedOn) }
        let request = CADBookOffRequestCore(callsign: lastBookOn.callsign)

        return CADStateManagerCore.apiManager.cadBookOff(with: request).done { [unowned self] in
            self.currentResource?.status = CADResourceStatusCore.offDuty
            self.lastBookOn = nil
        }
    }

    /// Update the status of our callsign
    open func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?, comments: String?, locationComments: String?) -> Promise<Void> {

        // TODO: Remove all hacks below when we have a real CAD system
        // We delay update to simulate receiving push notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            var newStatus = status
            var newIncident = incident

            // Finalise incident clears the current incident and sets state to On Air
            if newStatus == CADResourceStatusCore.finalise {
                self.finaliseIncident()
                newStatus = CADResourceStatusCore.onAir
                newIncident = nil
            }

            // Clear incident if changing to non incident status
            if (self.currentResource?.status.isChangingToGeneralStatus(newStatus)).isTrue {
                // Clear the current incident
                self.clearIncident()
                newIncident = nil
            }

            self.currentResource?.status = newStatus

            // Update current incident if setting status without one
            if let newIncident = newIncident, self.currentIncident == nil {
                if let syncDetails = self.lastSync, let resource = self.currentResource as? CADResourceCore {
                    resource.currentIncident = newIncident.identifier

                    // Make sure incident is also assigned to resource
                    var assignedIncidents = resource.assignedIncidents
                    if !assignedIncidents.contains(newIncident.identifier) {
                        assignedIncidents.append(newIncident.identifier)
                        resource.assignedIncidents = assignedIncidents
                    }

                    // Reposition resource at top so it is first one found assigned to incident
                    if let index = syncDetails.resources.index(where: { $0 == resource }) {
                        syncDetails.resources.remove(at: index)
                        syncDetails.resources.insert(resource, at: 0)
                    }
                }
            }
            NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
        }

        // TODO: Call method from API manager
        return after(seconds: 1.0).done {}
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

    /// Sync the latest manifest items
    /// We use our own implementation of update here, so we can use custom API manager
    open func syncManifestItems() -> Promise<Void> {
        let checkedAtDate = Date()

        let manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   path: "manifest/manifest",
                                                   method: .get,
                                                   updateType: .dateTime)
        return CADStateManagerCore.apiManager.fetchManifest(with: manifestRequest).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at:checkedAtDate)
        }.done { _ in
            self.lastManifestSyncTime = Date()
        }
    }

    
    /// Sync the latest manifest items for categories
    open func syncManifestItems(categories: [String]) -> Promise<Void> {
        let checkedAtDate = Date()
        
        let manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   path: "manifest/manifest/categories",
                                                   parameters: ["categories": categories],
                                                   method: .post, updateType: .dateTime)
        return CADStateManagerCore.apiManager.fetchManifest(with: manifestRequest).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at:checkedAtDate)
        }.done { _ in
            self.lastManifestSyncTime = Date()
        }
    }

    // MARK: - Sync

    /// Sync the latest task summaries
    open func syncDetails() -> Promise<Void> {
        // Perform sync and keep result
        return firstly {
            return after(seconds: 1.0)
        }.then { _ -> Promise<Void> in
            if let mapBoundingBox = self.mapBoundingBox, self.showsResultsOutsidePatrolGroup {
                return self.syncBoundingBox(mapBoundingBox, force: true)
            } else {
                // Perform sync and keep result
                return self.syncPatrolGroup(self.patrolGroup!)
            }
        }
    }
    
    public func syncPatrolGroup(_ patrolGroup: String) -> Promise<Void> {
        var promise: Promise<CADSyncResponseCore>
        // TODO: Remove this. For demos, we only get fresh data the first time
        if let lastSync = self.lastSync {
            promise = Promise<CADSyncResponseCore>.value(lastSync)
        } else {
            promise = CADStateManagerCore.apiManager.cadSyncSummaries(with: CADSyncPatrolGroupRequestCore(patrolGroup: self.patrolGroup!))
        }
        return promise.done { [unowned self] summaries -> Void in
            self.processSyncResponse(summaries)
        }
    }
    
    public func syncBoundingBox(_ boundingBox: MKMapView.BoundingBox, force: Bool) -> Promise<Void> {
        self.mapBoundingBox = boundingBox
        // TODO: Calculate whether it's worth moving
        let request = CADSyncBoundingBoxRequestCore(northWestCoordinate: boundingBox.northWest,
                                                  southEastCoordinate: boundingBox.southEast)
        return firstly {
            return CADStateManagerCore.apiManager.cadSyncSummaries(with: request)
        }.done { [unowned self] (summaries: CADSyncResponseCore) -> Void in
            self.processSyncResponse(summaries)
        }
    }
    
    private func processSyncResponse(_ response: CADSyncResponseCore) {
        self.lastSync = response
        self.lastSyncTime = Date()
        self.processSyncItems()
        NotificationCenter.default.post(name: .CADSyncChanged, object: self)
    }

    /// Perform initial sync after login or launching app
    open func syncInitial() -> Promise<Void> {
        return firstly {
            // Get details about logged in user
            return self.fetchCurrentOfficerDetails()
        }.then { [unowned self] _ in
            // Get new manifest items
            return self.syncManifestItems()
        }.then { [unowned self] _ in
            // Get sync details
            return self.syncDetails()
        }.done { _ -> Void in
            // Clear any outstanding shift ending notifications if we aren't booked on
            if self.lastBookOn == nil {
                NotificationManager.shared.removeLocalNotification(CADLocalNotifications.shiftEnding)
            }
        }
    }

    /// Process the last sync items for fast lookup
    open func processSyncItems() {
        if let syncDetails = lastSync {
            incidentsById.removeAll()
            for incident in syncDetails.incidents {
                incidentsById[incident.identifier] = incident
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
    
    // MARK: - Notifications
    
    /// Adds scheduled local notification and clears any conflicting ones.
    open func updateScheduledNotifications() {
        NotificationManager.shared.removeLocalNotification(CADLocalNotifications.shiftEnding)
        if let endTime = lastBookOn?.shiftEnd {
            NotificationManager.shared.postLocalNotification(withTitle: NSLocalizedString("Shift Ending", comment: ""),
                              body: NSLocalizedString("The shift time for your call sign has elapsed. Please terminate your shift or extend the end time.",
                                                      comment: ""),
                              at: endTime,
                              identifier: CADLocalNotifications.shiftEnding)
        }

    }

}
