//
//  ApiManager+Manifest.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import PromiseKit

extension Manifest {

    /// Convience function to fetch manifest without having to create your own fetchRequests
    ///
    /// - Parameters:
    ///   - collections: the collections to fetch. Pass in nil if you want a full fetch
    ///   - date: the date from which to fetch manifest since
    /// - Returns: a void promise defining whether the fetch was successful or not
    open func fetchManifest(collections: [ManifestCollection]? = nil, sinceDate date: Date? = Manifest.shared.lastUpdateDate) -> Promise<Void> {
        var removePrevious = false
        let manifestRequest: ManifestFetchRequest
        if let collections = collections {
            manifestRequest = ManifestFetchRequest(date: date,
                                                   fetchType: .partial(collections: collections))
        } else {
            manifestRequest = ManifestFetchRequest(date: date,
                                                   fetchType: .full)

            // Removing old manifest entries if syncing everything from beginning of time
            removePrevious = (date == nil)
        }
        return update(request: manifestRequest, removePrevious: removePrevious)
    }

    /// Uses the APIManager to connect and retrive the latest manifest with your specific fetch request
    /// If you don't want to bother using a specific fetch request, use the convienece function:
    ///
    /// `fetchManifest(collections: sinceDate)`
    ///
    /// - Parameter request: the manifest fetch request
    /// - Returns: a void promise defining whether the fetch was successful or not
    public func update(request: ManifestFetchRequest? = nil, removePrevious: Bool = false) -> Promise<Void> {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        let checkedAtDate = Date()

        // Use the provided manifest request or fallback to the old format used by DTMR
        let request = request ?? ManifestFetchRequest(date: self.lastUpdateDate)
        let newPromise = APIManager.shared.fetchManifest(with: request).then { [weak self] result -> Promise<Void> in
            guard let `self` = self else { return Promise<Void>.value(()) }
            guard result.isEmpty == false else {
                return Promise<Void>.value(())
            }

            return self.saveManifest(with: result, at: checkedAtDate, removePrevious: removePrevious)
        }
        return newPromise
    }
}
