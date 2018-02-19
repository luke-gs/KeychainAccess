//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import MPOLKit

open class CADStateManagerCore: CADStateManagerType {

    /// The API manager to use, by default system one
    open static var apiManager: CADAPIManager = APIManager.shared

    // MARK: - Synced State

    /// The logged in officer details
    open var officerDetails: CADOfficerType?
    
    /// The patrol group
    // TODO: Find out when to set/clear this value and where it's coming from
    open var patrolGroup: String = "Collingwood"

    /// The last book on data
    open var lastBookOn: CADBookOnDetailsType?

    /// The last sync data
    open private(set) var lastSync: SyncDetailsResponse?

    /// The last sync time
    open private(set) var lastSyncTime: Date?

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

    public init() {
        // Register concrete classes for protocols
        CADClientModelTypes.bookonDetails = BookOnRequest.self
        CADClientModelTypes.officerDetails = CADOfficerCore.self
        CADClientModelTypes.equipmentDetails = CADEquipmentCore.self
        CADClientModelTypes.resourceStatus = ResourceStatusCore.self
        CADClientModelTypes.resourceUnit = ResourceTypeCore.self
        CADClientModelTypes.incidentGrade = IncidentGradeCore.self
        CADClientModelTypes.incidentStatus = IncidentStatusCore.self
        CADClientModelTypes.broadcastCategory = BroadcastCategoryCore.self
        CADClientModelTypes.patrolStatus = PatrolStatusCore.self
    }

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

    open func fetchCurrentOfficerDetails() -> Promise<CADOfficerType> {
        let username = UserSession.current.user?.username
        return CADStateManagerCore.apiManager.cadOfficerByUsername(username: username!).then { [unowned self] details -> OfficerDetailsResponse in
            self.officerDetails = details
            return details
        }
    }

    /// Set logged in officer as off duty
    open func setOffDuty() {
        currentResource?.status = CADClientModelTypes.resourceStatus.offDutyCase
        lastBookOn = nil
    }
    
    /// Clears current incident and sets status to on air
    open func finaliseIncident() {
        currentResource?.status = CADClientModelTypes.resourceStatus.onAirCase
        clearIncident()
    }
    
    /// Un-assigns the current incident for the booked on resource
    open func clearIncident() {
        if let incident = currentIncident, let resource = currentResource {

            // Remove incident from being assigned to resource
            var assignedIncidents = resource.assignedIncidents ?? []
            if let index = assignedIncidents.index(of: incident.identifier) {
                assignedIncidents.remove(at: index)
                resource.assignedIncidents = assignedIncidents
            }
            resource.currentIncident = nil
        }
    }

    // MARK: - Shift

    /// Book on to a shift
    open func bookOn(request: CADBookOnDetailsType) -> Promise<Void> {

        // TODO: perform network request
        lastBookOn = request

        // TODO: remove this when we have a real CAD system
        if let lastBookOn = lastBookOn, let resource = self.currentResource {
            let officerIds = lastBookOn.officers.flatMap({ return $0.payrollId })

            // Update callsign for new officer list
            resource.payrollIds = officerIds

            // Set state if callsign was off duty
            if resource.status == CADClientModelTypes.resourceStatus.offDutyCase {
                resource.status = CADClientModelTypes.resourceStatus.onAirCase
            }

            // Check if logged in officer is no longer in callsign
            if let officerDetails = officerDetails, !officerIds.contains(officerDetails.payrollId) {
                // Treat like being booked off, using async to trigger didSet again
                DispatchQueue.main.async {
                    self.lastBookOn = nil
                }
            }
        }
        NotificationCenter.default.post(name: .CADBookOnChanged, object: self)
        addScheduledNotifications()

        return Promise<Void>()
    }

    /// Terminate shift
    open func bookOff(request: CADBookOffDetailsType) -> Promise<Void> {
        lastBookOn = nil
        return Promise<Void>()
    }

    /// Update the status of our callsign
    open func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?) {
        var newStatus = status
        var newIncident = incident

        // TODO: Remove all hacks below when we have a real CAD system

        // Finalise incident clears the current incident and sets state to On Air
        if newStatus == CADClientModelTypes.resourceStatus.finaliseCase {
            finaliseIncident()
            newStatus = CADClientModelTypes.resourceStatus.onAirCase
            newIncident = nil
        }

        // Clear incident if changing to non incident status
        if (currentResource?.status.isChangingToGeneralStatus(newStatus)).isTrue {
            // Clear the current incident
            CADStateManager.shared.clearIncident()
            newIncident = nil
        }

        currentResource?.status = newStatus

        // Update current incident if setting status without one
        if let newIncident = newIncident, currentIncident == nil {
            if let syncDetails = lastSync, let resource = currentResource as? CADResourceCore {
                resource.currentIncident = newIncident.identifier

                // Make sure incident is also assigned to resource
                var assignedIncidents = resource.assignedIncidents ?? []
                if !assignedIncidents.contains(newIncident.identifier) {
                    assignedIncidents.append(newIncident.identifier)
                    resource.assignedIncidents = assignedIncidents
                }

                // Reposition resource at top so it is first one found assigned to incident
                if let index = syncDetails.resources.index(of: resource) {
                    syncDetails.resources.remove(at: index)
                    syncDetails.resources.insert(resource, at: 0)
                }
            }
        }
        NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
    }

    // MARK: - Manifest

    /// Fetch the book on equipment items
    open func equipmentItems() -> [ManifestEntry] {
        return Manifest.shared.entries(for: .EquipmentCollection) ?? []
    }

    open func equipmentItemsByTitle() -> [String: ManifestEntry] {
        var result: [String: ManifestEntry] = [:]
        for item in equipmentItems() {
            if let title = item.title {
                result[title] = item
            }
        }
        return result
    }
    
    /// Fetch the patrol groups
    open func patrolGroups() -> [ManifestEntry] {
        return Manifest.shared.entries(for: .PatrolGroupCollection) ?? []
    }

    /// Sync the latest manifest items
    /// We use our own implementation of update here, so we can use custom API manager
    open func syncManifestItems() -> Promise<Void> {
        let checkedAtDate = Date()
        return CADStateManagerCore.apiManager.fetchManifest(with: ManifestFetchRequest(date: Manifest.shared.lastUpdateDate)).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at:checkedAtDate)
        }
    }

    // MARK: - Sync

    /// Sync the latest task summaries
    open func syncDetails() -> Promise<Void> {
        // Perform sync and keep result
        return firstly {
            return after(seconds: 1.0)
        }.then { _ -> Promise<SyncDetailsResponse> in
            // TODO: Remove this. For demos, we only get fresh data the first time
            if let lastSync = self.lastSync {
                return Promise<SyncDetailsResponse>(value: lastSync)
            }
            return CADStateManagerCore.apiManager.cadSyncDetails(request: SyncDetailsRequest())
        }.then { [unowned self] summaries -> Void in
            self.lastSync = summaries
            self.lastSyncTime = Date()
            self.processSyncItems()
            NotificationCenter.default.post(name: .CADSyncChanged, object: self)
        }
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
        }.then { _ -> Void in
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
        var resources: [CADResourceCore] = []
        if let syncDetails = lastSync {
            for resource in syncDetails.resources {
                if resource.assignedIncidents?.contains(incidentNumber) == true {
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
        if let resource = resourcesById[callsign], let payrollIds = resource.payrollIds {
            for payrollId in payrollIds {
                if let officer = officersById[payrollId] {
                    officers.append(officer)
                }
            }
        }
        return officers
    }
    
    // MARK: - Notifications
    
    /// Adds scheduled local notification and clears any conflicting ones.
    open func addScheduledNotifications() {
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
