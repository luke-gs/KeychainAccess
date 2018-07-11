//
//  ApiManager+Manifest.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import PromiseKit

extension Manifest {

    open func fetchManifest(collections: [ManifestCollection]? = nil, sinceDate date: Date? = Manifest.shared.lastUpdateDate) -> Promise<Void> {
        let manifestRequest: ManifestFetchRequest
        if let collections = collections {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   fetchType: .partial(collections: collections))
        } else {
            manifestRequest = ManifestFetchRequest(date: Manifest.shared.lastUpdateDate,
                                                   fetchType: .full)
        }
        return update(request: manifestRequest)
    }

    /// Uses the APIManager to connect and retrive the latest manifest, using the lastUpdateDate as a Delta
    ///
    /// - Return: A promise that returns the successful result once complete
    ///
    public func update(request: ManifestFetchRequest? = nil) -> Promise<Void> {
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

            return self.saveManifest(with: result, at:checkedAtDate)
        }
        return newPromise
    }
}
