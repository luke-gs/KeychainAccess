//
//  DemoAPIManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// API manager for demo data. Unfortunately due to Swift sucking i can't make this a subclass
/// of APIManager and override methods, due to them being in extensions.
///
/// Instead, i created a CADAPIManager protocol that the state manager uses rather than a subclassed APIManager.
open class DemoAPIManager: CADAPIManager {

    open static let shared = DemoAPIManager()

    open func cadOfficerByUsername(username: String) -> Promise<OfficerDetailsResponse> {
        let response = OfficerDetailsResponse()
        return Promise<OfficerDetailsResponse>(value: response)
    }

    open func cadSyncDetails(request: SyncDetailsRequest) -> Promise<SyncDetailsResponse> {
        let response = SyncDetailsResponse()
        return Promise<SyncDetailsResponse>(value: response)
    }

    open func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass> {
        if let url = Bundle.mpolKit.url(forResource: "DemoManifest", withExtension: "json", subdirectory: "") {
            let data = try! Data(contentsOf: url)
            if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? ManifestFetchRequest.ResultClass {
                return Promise<ManifestFetchRequest.ResultClass>(value: json)
            }
        }
        return Promise<ManifestFetchRequest.ResultClass>(value: [[:]])
    }
}
