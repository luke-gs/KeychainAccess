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

    // MARK: - Shared

    open func accessTokenRequest(for grant: OAuthAuthorizationGrant) -> Promise<OAuthAccessToken> {
        return APIManager.shared.accessTokenRequest(for: grant)

        // Create dummy token
        // let token = OAuthAccessToken(accessToken: "123", type: "Bearer")
        // return Promise<OAuthAccessToken>.value(token)
    }

    open func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass> {
        if let json = loadDemoFileAsJson(name: "DemoManifest") as? ManifestFetchRequest.ResultClass {
            return Promise<ManifestFetchRequest.ResultClass>.value(json)
        }
        return Promise<ManifestFetchRequest.ResultClass>.value([[:]])
    }

    // MARK: - CAD

    public func cadBookOn(with request: CADBookOnRequestType, pathTemplate: String?) -> Promise<Void> {
        print("\(LogUtils.string(from: request.parameters))")
        return after(seconds: 1).done {}
    }

    public func cadBookOff(with request: CADBookOffRequestType, pathTemplate: String?) -> Promise<Void> {
        print("\(LogUtils.string(from: request.parameters))")
        return after(seconds: 1).done {}
    }

    open func cadEmployeeDetails<ResponseType: CADEmployeeDetailsResponseType>(with request: CADEmployeeDetailsRequestType, pathTemplate: String?) -> Promise<ResponseType> {
        if let data = loadDemoFileAsData(name: "DemoOfficer") {
            let response = try! JSONDecoder.decode(data, to: CADEmployeeDetailsResponseCore.self)
            return Promise<CADEmployeeDetailsResponseCore>.value(response) as! Promise<ResponseType>
        }
        return Promise<ResponseType>(error: APIError.fileNotFound)
    }

    open func cadSyncSummaries<ResponseType: CADSyncResponseType>(with request: CADSyncRequestType, pathTemplate: String?) -> Promise<ResponseType> {
        if let data = loadDemoFileAsData(name: "DemoSync") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = ISO8601DateTransformer.jsonDateDecodingStrategy()
            let response = try! decoder.decode(CADSyncResponseCore.self, from: data)
            return Promise<CADSyncResponseCore>.value(response) as! Promise<ResponseType>
        }
        return Promise<ResponseType>(error: APIError.fileNotFound)
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
