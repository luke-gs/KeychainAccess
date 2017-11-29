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
    /// Notification posted when callsign status changes
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

    /// The currently booked on callsign, or nil
    open var callsign: String? {
        didSet {
            NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
        }
    }

    /// The logged in officer details
    open var officerDetails: OfficerDetailsResponse?

    /// The last book on data
    open var lastBookOn: BookOnRequest?

    /// The last sync data
    open var lastSync: SyncDetailsResponse?

    /// The last sync time
    open var lastSyncTime: Date?

    // MARK: - Officer

    open func fetchOfficerDetails() -> Promise<OfficerDetailsResponse> {
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
            NotificationCenter.default.post(name: .CADSyncChanged, object: self)
            return summaries
        }
    }

    /// Perform initial sync after login or launching app
    open func syncInitial() -> Promise<Void> {
        return firstly {
            // Get details about logged in user
            return self.fetchOfficerDetails()
        }.then { [unowned self] _ in
            // Get new manifest items
            return self.syncManifestItems()
        }.then { [unowned self] _ in
            // Get sync details
            return self.syncDetails()
        }.then { _ -> Void in
        }
    }
}
