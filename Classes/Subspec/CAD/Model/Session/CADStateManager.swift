//
//  CADStateManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

public extension NSNotification.Name {

    /// Notification posted when callsign status changes
    static let CADCallsignChanged = NSNotification.Name(rawValue: "CAD_CallsignChanged")
    static let CADSyncChanged = NSNotification.Name(rawValue: "CAD_SyncChanged")
}

open class CADStateManager: NSObject {

    /// The singleton state monitor.
    open static let shared = CADStateManager()

    /// The currently booked on callsign, or nil
    open var callsign: String? {
        didSet {
            NotificationCenter.default.post(name: .CADCallsignChanged, object: self)
        }
    }

    /// The last sync data
    open var lastSync: CADSyncSummaries?

    /// The last sync time
    open var lastSyncTime: Date?

    /// Sync the latest manifest items
    open func syncManifestItems() -> Promise<Void> {
        print("Syncing manifest items")
        return Manifest.shared.update()
    }

    /// Sync the latest task summaries
    open func syncSummaries() -> Promise<CADSyncSummaries> {
        // Perform sync and keep result
        print("Syncing summaries")
        return firstly {
            return APIManager.shared.cadSyncSummaries()
        }.then { [unowned self] summaries -> CADSyncSummaries in
            self.lastSync = summaries
            self.lastSyncTime = Date()
            NotificationCenter.default.post(name: .CADSyncChanged, object: self)
            return summaries
        }
    }

    /// Perform initial sync after login or launching app
    open func syncInitial() -> Promise<Void> {
        // Syncing is disabled for now for demoing purposes, due to backend issues
        return after(interval: 2)

        guard let username = UserSession.current.user?.username else { fatalError("Must be logged in to sync") }

        print("Starting initial sync")
        return firstly {
            // Get details about logged in user
            return APIManager.shared.cadOfficerByUsername(username: username)
        }.then { [unowned self] _ in
            // Get sync summaries
            return self.syncSummaries()
        }.then { [unowned self] _ -> Promise<Void> in
            // Get new manifest items
            return self.syncManifestItems()
        }.then { _ in
            print("Sync complete")
        }
    }
}
