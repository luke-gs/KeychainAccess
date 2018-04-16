//
//  DemoAPIManager.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import MPOLKit
import ClientKit

enum APIError: Error {
    case fileNotFound
}

/// API manager for demo data. Unfortunately due to Swift sucking i can't make this a subclass
/// of APIManager and override methods, due to them being in extensions.
///
/// Instead, i created a CADAPIManager protocol that the state manager uses rather than a subclassed APIManager.
open class DemoAPIManager: CADAPIManagerType {

    open static let shared = DemoAPIManager()

    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken> {
        // Create dummy token
        let token = OAuthAccessToken(accessToken: "123", type: "Bearer")
        return Promise<OAuthAccessToken>.value(token)
    }

    public func cadBookOn(with request: CADBookOnRequestType) -> Promise<Void> {
        return after(seconds: 1).done {}
    }

    open func cadOfficerByUsername(username: String) -> Promise<CADOfficerDetailsResponse> {
        if let data = loadDemoFileAsData(name: "DemoOfficer") {
            let response = try! JSONDecoder.decode(data, to: CADOfficerDetailsResponse.self)
            return Promise<CADOfficerDetailsResponse>.value(response)
        }
        return Promise<CADOfficerDetailsResponse>(error: APIError.fileNotFound)
    }

    open func cadSyncDetails(request: CADSyncRequest) -> Promise<CADSyncResponse> {
        if let data = loadDemoFileAsData(name: "DemoSync") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try! decoder.decode(CADSyncResponse.self, from: data)
            return Promise<CADSyncResponse>.value(response)
        }
        return Promise<CADSyncResponse>(error: APIError.fileNotFound)
    }

    open func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass> {
        if let json = loadDemoFileAsJson(name: "DemoManifest") as? ManifestFetchRequest.ResultClass {
            return Promise<ManifestFetchRequest.ResultClass>.value(json)
        }
        return Promise<ManifestFetchRequest.ResultClass>.value([[:]])
    }

    open func loadDemoFileAsJson(name: String) -> Any? {
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            let data = try! Data(contentsOf: url)
            return try! JSONSerialization.jsonObject(with: data, options: [])
        }
        return nil
    }

    open func loadDemoFileAsData(name: String) -> Data? {
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            return try! Data(contentsOf: url)
        }
        return nil
    }
}
