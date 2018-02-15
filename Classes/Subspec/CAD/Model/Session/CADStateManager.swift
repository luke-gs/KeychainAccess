//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

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

open class CADStateManager: NSObject {

    public struct Notifications {
        public static let shiftEnding = "CADShiftEndingNotification"
    }
    
    /// The singleton state monitor.
    open static var shared = CADStateManager()

    /// The API manager to use, by default system one
    open static var apiManager: CADAPIManager = APIManager.shared

    // MARK: - Synced State

    /// The logged in officer details
    open var officerDetails: OfficerDetailsResponse?
    
    /// The patrol group
    // TODO: Find out when to set/clear this value and where it's coming from
    open var patrolGroup: String = "Collingwood"

    /// The last book on data
    open private(set) var lastBookOn: BookOnRequest?

    /// The last sync data
    open private(set) var lastSync: SyncDetailsResponse?

    /// The last sync time
    open private(set) var lastSyncTime: Date?

    /// Incidents retrieved in last sync, keyed by incidentNumber
    open private(set) var incidentsById: [String: SyncDetailsIncident] = [:]

    /// Resources retrieved in last sync, keyed by callsign
    open private(set) var resourcesById: [String: SyncDetailsResource] = [:]

    /// Officers retrieved in last sync, keyed by payrollId
    open private(set) var officersById: [String: SyncDetailsOfficer] = [:]

    /// The currently booked on resource
    open var currentResource: SyncDetailsResource? {
        if let bookOn = CADStateManager.shared.lastBookOn {
            return CADStateManager.shared.resourcesById[bookOn.callsign]
        }
        return nil
    }

    /// The current incident for my callsign
    open var currentIncident: SyncDetailsIncident? {
        if let bookOn = CADStateManager.shared.lastBookOn {
            return CADStateManager.shared.incidentForResource(callsign: bookOn.callsign)
        }
        return nil
    }

    // MARK: - Officer

    open func fetchCurrentOfficerDetails() -> Promise<OfficerDetailsResponse> {
        let username = UserSession.current.user?.username
        return CADStateManager.apiManager.cadOfficerByUsername(username: username!).then { [unowned self] details -> OfficerDetailsResponse in
            self.officerDetails = details
            return details
        }
    }

    /// Set logged in officer as off duty
    open func setOffDuty() {
        currentResource?.statusType = ClientModelTypes.resourceStatus.offDutyCase
        lastBookOn = nil
    }
    
    /// Clears current incident and sets status to on air
    open func finaliseIncident() {
        currentResource?.statusType = ClientModelTypes.resourceStatus.onAirCase
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
    open func bookOn(request: BookOnRequest) -> Promise<Void> {

        // TODO: perform network request
        lastBookOn = request

        // TODO: remove this when we have a real CAD system
        if let lastBookOn = lastBookOn, let resource = self.currentResource {
            let officerIds = lastBookOn.officers.flatMap({ return $0.payrollId })

            // Update callsign for new officer list
            resource.payrollIds = officerIds

            // Set state if callsign was off duty
            if resource.statusType == ClientModelTypes.resourceStatus.offDutyCase {
                resource.statusType = ClientModelTypes.resourceStatus.onAirCase
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
    open func bookOff(request: BookOffRequest) -> Promise<Void> {
        lastBookOn = nil
        return Promise<Void>()
    }

    /// Update the status of our callsign
    open func updateCallsignStatus(status: ResourceStatusType, incident: SyncDetailsIncident?) {
        var newStatus = status
        var newIncident = incident

        // TODO: Remove all hacks below when we have a real CAD system

        // Finalise incident clears the current incident and sets state to On Air
        if newStatus == ClientModelTypes.resourceStatus.finaliseCase {
            finaliseIncident()
            newStatus = ClientModelTypes.resourceStatus.onAirCase
            newIncident = nil
        }

        // Clear incident if changing to non incident status
        if (currentResource?.statusType.isChangingToGeneralStatus(newStatus)).isTrue {
            // Clear the current incident
            CADStateManager.shared.clearIncident()
            newIncident = nil
        }

        currentResource?.statusType = newStatus

        // Update current incident if setting status without one
        if let newIncident = newIncident, currentIncident == nil {
            if let syncDetails = lastSync, let resource = currentResource {
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
        return CADStateManager.apiManager.fetchManifest(with: ManifestFetchRequest(date: Manifest.shared.lastUpdateDate)).then { result -> Promise<Void> in
            return Manifest.shared.saveManifest(with: result, at:checkedAtDate)
        }
    }

    // MARK: - Sync

    /// Sync the latest task summaries
    open func syncDetails() -> Promise<SyncDetailsResponse> {
        // Perform sync and keep result
        return firstly {
            return after(seconds: 1.0)
        }.then { _ -> Promise<SyncDetailsResponse> in
            // TODO: Remove this. For demos, we only get fresh data the first time
            if let lastSync = self.lastSync {
                return Promise<SyncDetailsResponse>(value: lastSync)
            }
            return CADStateManager.apiManager.cadSyncDetails(request: SyncDetailsRequest())
        }.then { [unowned self] summaries -> SyncDetailsResponse in
            self.lastSync = summaries
            self.lastSyncTime = Date()
            self.processSyncItems()
            NotificationCenter.default.post(name: .CADSyncChanged, object: self)
            return summaries
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
                NotificationManager.shared.removeLocalNotification(CADStateManager.Notifications.shiftEnding)
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
    open func resourcesForIncident(incidentNumber: String) -> [SyncDetailsResource] {
        var resources: [SyncDetailsResource] = []
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
    open func incidentForResource(callsign: String) -> SyncDetailsIncident? {
        if let resource = resourcesById[callsign], let incidentId = resource.currentIncident {
            return incidentsById[incidentId]
        }
        return nil
    }

    /// Return all officers linked to a resource
    open func officersForResource(callsign: String) -> [SyncDetailsOfficer] {
        var officers: [SyncDetailsOfficer] = []
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
        NotificationManager.shared.removeLocalNotification(CADStateManager.Notifications.shiftEnding)
        if let endTime = lastBookOn?.shiftEnd {
            NotificationManager.shared.postLocalNotification(withTitle: NSLocalizedString("Shift Ending", comment: ""),
                              body: NSLocalizedString("The shift time for your call sign has elapsed. Please terminate your shift or extend the end time.",
                                                      comment: ""),
                              at: endTime,
                              identifier: CADStateManager.Notifications.shiftEnding)
        }

    }
    

}
