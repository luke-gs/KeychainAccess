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
}

open class CADStateManager: NSObject {

    /// The singleton state monitor.
    open static let shared = CADStateManager()

    /// The API manager to use, by default system one
    open static var apiManager: CADAPIManager = APIManager.shared

    /// The logged in officer details
    open var officerDetails: OfficerDetailsResponse?

    /// The last book on data
    open var lastBookOn: BookOnRequest? {
        didSet {
            NotificationCenter.default.post(name: .CADBookOnChanged, object: self)
        }
    }

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

    // MARK: - Officer

    open func fetchCurrentOfficerDetails() -> Promise<OfficerDetailsResponse> {
        let username = UserSession.current.user?.username
        return CADStateManager.apiManager.cadOfficerByUsername(username: username!).then { [unowned self] details -> OfficerDetailsResponse in
            self.officerDetails = details
            return details
        }
    }

    // MARK: - Shift

    /// Book on to a shift
    open func bookOn(request: BookOnRequest) -> Promise<Void> {
        lastBookOn = request
        return Promise<Void>()
    }

    /// Terminate shift
    open func bookOff(request: BookOffRequest) -> Promise<Void> {
        lastBookOn = nil
        return Promise<Void>()
    }

    /// Update the status of our callsign
    open func updateCallsignStatus(status: ResourceStatus) {
        currentResource?.status = status
        NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
    }

    // MARK: - Manifest

    /// Fetch the book on equipment items, returning as a dictionary of titles keyed by id
    open func equipmentItems() -> [String: String] {
        var result: [String: String] = [:]
        if let manifestItems = Manifest.shared.entries(for: .EquipmentCollection) {
            manifestItems.forEach {
                if let id = $0.id, let title = $0.title {
                    result[id] = title
                }
            }
        }
        return result
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
        }.then { _ in
            return after(seconds: 2.0)
        }.then { [unowned self] _ in
            // Get new manifest items
            return self.syncManifestItems()
        }.then { [unowned self] _ in
            // Get sync details
            return self.syncDetails()
        }.then { _ -> Void in
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
        }
    }

    /// Return all resources linked to an incident
    open func resourcesForIncident(incidentNumber: String) -> [SyncDetailsResource] {
        var resources: [SyncDetailsResource] = []
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
    open func incidentForResource(callsign: String) -> SyncDetailsIncident? {
        if let resource = resourcesById[callsign], let incidentId = resource.currentIncident {
            return incidentsById[incidentId]
        }
        return nil
    }

    /// Return all officers linked to a resource
    open func officersForResource(callsign: String) -> [SyncDetailsOfficer] {
        var officers: [SyncDetailsOfficer] = []
        if let resource = resourcesById[callsign] {
            for payrollId in resource.payrollIds {
                if let officer = officersById[payrollId] {
                    officers.append(officer)
                }
            }
        }
        return officers
    }
}
