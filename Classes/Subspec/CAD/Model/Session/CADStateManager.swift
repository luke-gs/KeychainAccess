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
    static let CallsignChanged = NSNotification.Name(rawValue: "CAD_CallsignChanged")
}

open class CADStateManager: NSObject {

    /// The singleton state monitor.
    open static let shared = CADStateManager()

    /// The currently booked on callsign, or nil
    open var callsign: String? {
        didSet {
            NotificationCenter.default.post(name: .CallsignChanged, object: self)
        }
    }

    /// The last sync
    open var lastSync: CADSyncSummaries?

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
            return summaries
        }
    }

    /// Perform initial sync after login or launching app
    open func syncInitial() -> Promise<Void> {
        #if DEBUG
            return after(interval: 2)
        #endif

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
