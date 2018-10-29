//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import DemoAppKit

/// PSCore implementation of CAD state manager
open class CADStateManagerCore: CADStateManagerBase {

    public override init(apiManager: CADAPIManagerType) {
        super.init(apiManager: apiManager)

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

        // Register serialisation methods for CAD officers
        CADBookOnRequestCore.encodeOfficers = { (container, key, officers) in
            var container = container
            if let officers = officers as? [CADOfficerCore] {
                try container.encodeIfPresent(officers, forKey: key)
            }
        }

        CADSyncResponseCore.decodeOfficers = { (container, key) in
            return try container.decodeIfPresent([CADOfficerCore].self, forKey: key) ?? []
        }

        // Default patrol group for demo data
        patrolGroup = "Collingwood"
    }

    private var currentOfficer: CADOfficerType?

    open override var officerDetails: CADOfficerType? {

        guard currentOfficer == nil else {
            return currentOfficer
        }

        // get current search officer
        if let details = getEmployeeDetails() {
            currentOfficer = details
            officersById[details.id] = details
            return details
        }
        return nil
    }

    open override func didChangeLastBookOn(from oldValue: CADBookOnRequestType?) {
        super.didChangeLastBookOn(from: oldValue)
        updateScheduledNotifications()
    }

    // MARK: - Book On

    /// Book on to a shift
    open override func bookOn(request: CADBookOnRequestType) -> Promise<Void> {

        // Perform book on to server
        return apiManager.cadBookOn(with: request).done { [unowned self] in

            // Update book on and notify observers
            self.lastSyncTime = Date()
            self.lastBookOn = request

            // Store recent IDs
            try? UserPreferenceManager.shared.addRecentId(request.callsign, forKey: .recentCallsigns)

            // TODO: remove this when we have a real CAD system
            if let lastBookOn = self.lastBookOn, let resource = self.currentResource {
                let officerIds = lastBookOn.employees.map { $0.id }

                // Update ids for new officer list
                resource.officerIds = officerIds

                // Update call sign for new equipment list
                resource.equipment = lastBookOn.equipment

                // Set state if callsign was off duty
                if resource.status == CADResourceStatusCore.offDuty {
                    resource.status = CADResourceStatusCore.onAir
                }

                // Check if logged in officer is no longer in callsign
                if let officerDetails = self.officerDetails, !officerIds.contains(officerDetails.id) {
                    // Treat like being booked off, using async to trigger didSet again
                    DispatchQueue.main.async {
                        self.lastBookOn = nil
                    }
                }
            }
        }
    }

    /// Terminate shift
    open override func bookOff() -> Promise<Void> {
        guard let lastBookOn = lastBookOn else { return Promise<Void>(error: CADStateManagerError.notBookedOn) }
        let request = CADBookOffRequestCore(callsign: lastBookOn.callsign)

        return apiManager.cadBookOff(with: request).done { [unowned self] in
            self.currentResource?.status = CADResourceStatusCore.offDuty
            self.lastBookOn = nil
        }
    }

    /// Update the status of our callsign
    open override func updateCallsignStatus(status: CADResourceStatusType, incident: CADIncidentType?, comments: String?, locationComments: String?) -> Promise<Void> {

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
                if let incident = self.currentIncident, let resource = self.currentResource {
                    self.clearIncident(incidentNumber: incident.incidentNumber, from: resource)
                }
                newIncident = nil
            }

            self.currentResource?.status = newStatus

            // Update current incident if setting status without one
            if let newIncident = newIncident, self.currentIncident == nil {
                if let syncDetails = self.lastSync, let resource = self.currentResource as? CADResourceCore {
                    resource.currentIncident = newIncident.incidentNumber

                    // Make sure incident is also assigned to resource
                    var assignedIncidents = resource.assignedIncidents
                    if !assignedIncidents.contains(newIncident.incidentNumber) {
                        assignedIncidents.append(newIncident.incidentNumber)
                        resource.assignedIncidents = assignedIncidents
                    }

                    // Reposition resource at top so it is first one found assigned to incident
                    if let index = syncDetails.resources.index(where: { $0 == resource }) {
                        if var resources = syncDetails.resources as? [CADResourceCore] {
                            resources.remove(at: index)
                            resources.insert(resource, at: 0)
                        }
                    }
                }
            }
            NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
        }

        // TODO: Call method from API manager
        return after(seconds: 1.0).done {}
    }

    /// Clears current incident and sets status to on air
    private func finaliseIncident() {
        // TODO: remove this when we have a real CAD system
        currentResource?.status = CADResourceStatusCore.onAir
        if let syncDetails = lastSync as? CADSyncResponseCore, let incidentNumber = currentIncident?.incidentNumber {

            // Remove incident from any assigned resource
            let resources = resourcesForIncident(incidentNumber: incidentNumber)
            for resource in resources {
                clearIncident(incidentNumber: incidentNumber, from: resource)
            }

            // Remove incident from incident list
            syncDetails.incidents = syncDetails.incidents.filter { $0.incidentNumber != incidentNumber }
            incidentsById.removeValue(forKey: incidentNumber)

            // Trigger UI update like sync has occurred
            lastSyncTime = Date()
            NotificationCenter.default.post(name: .CADSyncChanged, object: self)
        }
    }

    /// Un-assigns the current incident for the booked on resource
    private func clearIncident(incidentNumber: String, from resource: CADResourceType) {
        // Remove incident from being assigned to resource
        var assignedIncidents = resource.assignedIncidents
        if let index = assignedIncidents.index(of: incidentNumber) {
            assignedIncidents.remove(at: index)
            resource.assignedIncidents = assignedIncidents
        }
        if resource.currentIncident == incidentNumber {
            resource.currentIncident = nil
        }
    }

    // MARK: - Get Details

    /// Fetch details for current user
    open func getEmployeeDetails() -> CADOfficerType? {
        // update current employee with current search officer details
        guard let currentSearchOfficer = UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey) as? Officer else {
            return nil
        }

        // init CADOfficer using search officer data
        let officer = CADOfficerCore(id: currentSearchOfficer.id)
        officer.givenName = currentSearchOfficer.givenName
        officer.familyName = currentSearchOfficer.familyName
        officer.middleNames = currentSearchOfficer.middleNames
        officer.employeeNumber = currentSearchOfficer.employeeNumber
        officer.rank = currentSearchOfficer.rank
        officer.region = currentSearchOfficer.region

        // add data for extra CADOfficer fields
        // TODO: update to use real data (currently using fake data for demo)
        officer.capabilities = []
        officer.contactNumber = "0425 584 678"
        officer.licenceTypeId = "b50862f7-961a-43d6-9111-0f43d0787503"
        officer.patrolGroup = "Collingwood"
        officer.radioId = "92757488"
        officer.remarks = ""
        officer.station = "Collingwood Station"

        officersById[officer.id] = officer
        return officer
    }

    /// Fetch details for a specific incident
    open override func getIncidentDetails(identifier: String) -> Promise<CADIncidentDetailsType> {
        let request = CADGetDetailsRequestCore(identifier: identifier)
        // Provide specific core model type information to generic call via map with explicit type
        return apiManager.cadIncidentDetails(with: request).map { (details: CADIncidentCore) -> CADIncidentDetailsType in
            return details
        }
    }

    /// Fetch details for a specific resource
    open override func getResourceDetails(identifier: String) -> Promise<CADResourceDetailsType> {
        let request = CADGetDetailsRequestCore(identifier: identifier)
        // Provide specific core model type information to generic call via map with explicit type
        return apiManager.cadResourceDetails(with: request).map { (details: CADResourceCore) -> CADResourceDetailsType in
            return details
        }
    }

    // MARK: - Sync

    /// Perform initial sync after login or launching app
    open override func syncInitial() -> Promise<Void> {
        return firstly {
            // Get all new manifest items
            return self.syncManifestItems(collections: nil)
        }.then { [unowned self] _ in
            // Get sync details
            return self.syncDetails()
        }.done { [unowned self] _ -> Void in
            // Clear any outstanding shift ending notifications if we aren't booked on
            if self.lastBookOn == nil {
                NotificationManager.shared.removeLocalNotification(CADLocalNotifications.shiftEnding)
            }
        }
    }

    /// Sync the latest task summaries
    open override func syncDetails(force: Bool) -> Promise<Void> {
        // TODO: Remove this. For demos, we only get fresh data the first time
        if let lastSync = self.lastSync {
            return after(seconds: 1).map {
                return lastSync
            }.done { [unowned self] summaries in
                self.processSyncResponse(summaries)
            }
        }
        return super.syncDetails(force: force)
    }

    open override func syncPatrolGroup(_ patrolGroup: String) -> Promise<Void> {
        return firstly {
            return apiManager.cadSyncSummaries(with: CADSyncPatrolGroupRequestCore(patrolGroup: patrolGroup))
        }.done { [unowned self] (summaries: CADSyncResponseCore) -> Void in
            self.processSyncResponse(summaries)
        }
    }

    open override func syncBoundingBox(_ boundingBox: MKMapRect.BoundingBox, force: Bool = false) -> Promise<Void> {
        // Check whether new sync is required
        if !requiresSyncForBoundingBox(boundingBox) && !force {
            return Promise<Void>()
        }

        // Perform sync
        self.lastSyncMapBoundingBox = boundingBox
        let request = CADSyncBoundingBoxRequestCore(northWestCoordinate: boundingBox.northWest,
                                                    southEastCoordinate: boundingBox.southEast)
        return firstly {
            return apiManager.cadSyncSummaries(with: request)
        }.done { [unowned self] (summaries: CADSyncResponseCore) -> Void in
            self.processSyncResponse(summaries)
        }
    }

    open override func processSyncItems() {
        super.processSyncItems()

        // TODO: remove this when we have a real CAD system
        // Update booked on resources to have shift times from today
        if let lastSync = lastSync {
            for resource in lastSync.resources {
                if resource.shiftStart != nil {
                    resource.shiftStart = Date().beginningOfDay.adding(hours: 9)
                    resource.shiftEnd = Date().beginningOfDay.adding(hours: 9+8)
                }
            }
        }
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

    /// Clears all session data properties
    @objc open override func clearSession() {
        super.clearSession()
        self.currentOfficer = nil
    }
}
