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
open class CADStateManagerCore: CADStateManagerBase {

    public override init(apiManager: CADAPIManagerType) {
        super.init(apiManager: apiManager)

        // Default patrol group for demo data
        patrolGroup = "Collingwood"
    }

    open override func didChangeLastBookOn(from oldValue: CADBookOnRequestType?) {
        super.didChangeLastBookOn(from: oldValue)
        updateScheduledNotifications()
    }

    // MARK: - Officer

    open override func fetchCurrentOfficerDetails() -> Promise<CADEmployeeDetailsType> {
        if let username = UserSession.current.user?.username {
            let request = CADEmployeeDetailsRequestCore(identifier: username)
            let promise: Promise<CADEmployeeDetailsCore> = apiManager.cadEmployeeDetails(with: request, pathTemplate: nil)
            return promise.map { [unowned self] details in
                self.officerDetails = details
                return details
            }
        }
        
        return Promise(error: CADStateManagerError.notLoggedIn)
    }

    // MARK: - Book On

    /// Book on to a shift
    open override func bookOn(request: CADBookOnRequestType) -> Promise<Void> {

        // Perform book on to server
        return apiManager.cadBookOn(with: request).done { [unowned self] in

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
                self.clearIncident()
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
        currentResource?.status = CADResourceStatusCore.onAir
        clearIncident()
    }

    /// Un-assigns the current incident for the booked on resource
    private func clearIncident() {
        if let incident = currentIncident, let resource = currentResource {

            // Remove incident from being assigned to resource
            var assignedIncidents = resource.assignedIncidents
            if let index = assignedIncidents.index(of: incident.incidentNumber) {
                assignedIncidents.remove(at: index)
                resource.assignedIncidents = assignedIncidents
            }
            resource.currentIncident = nil
        }
    }

    // MARK: - Sync

    /// Perform initial sync after login or launching app
    open override func syncInitial() -> Promise<Void> {
        return firstly {
            // Get details about logged in user
            return self.fetchCurrentOfficerDetails()
            }.then { [unowned self] _ in
                // Get new manifest items
                return self.syncManifestItems(categories: nil)
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

    open override func syncBoundingBox(_ boundingBox: MKMapView.BoundingBox, force: Bool = false) -> Promise<Void> {
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
