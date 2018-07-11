//
//  ManifestFetchRequest.swift
//  Alamofire
//
//  Created by Valery Shorinov on 22/11/17.
//

import Foundation
import PromiseKit
import Alamofire

public enum ManifestFetchType: Equatable {
    case full
    case partial(collections: [ManifestCollection])

    var path: String {
        switch self {
        case .full:
            return "manifest/manifest"
        case .partial(_):
            return "manifest/manifest/categories"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .full:
            return .get
        case .partial:
            return .post
        }
    }

    public static func ==(lhs: ManifestFetchType, rhs: ManifestFetchType) -> Bool {
        switch (lhs, rhs) {
        case (.partial, .full), (.full, .partial):
            return false
        default:
            return true
        }
    }
}

public struct ManifestFetchRequest: Parameterisable {

    public typealias ResultClass = [[String:Any]]

    public let parameters: [String: Any]
    public let path: String
    public let method: HTTPMethod

    public init(date: Date?, fetchType: ManifestFetchType = .full) {
        var parameters = [String: Any]()

        // Set the date back 60 seconds to account for clock skew
        let date = date?.adding(seconds: -60)

        // Convert date to ISO8601
        if let dateString = ISO8601DateTransformer.shared.reverse(date) {
            parameters["dateLastUpdated"] = dateString
        }

        switch fetchType {
        case .full:
            break
        case .partial(let collections):
            let categories = collections.map { $0.rawValue }
            parameters = ["categories": categories]
        }

        self.path = fetchType.path
        self.method = fetchType.method
        self.parameters = parameters
    }
}

public extension APIManager {

    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass> {
        // Use JSON encoding if POST/PUT/PATCH, otherwise use default URL encoding
        let parameterEncoding: ParameterEncoding = [HTTPMethod.post, .put, .patch].contains(request.method) ? JSONEncoding.default : URLEncoding.queryString

        let networkRequest = try! NetworkRequest(pathTemplate: request.path,
                                                 parameters: request.parameters,
                                                 method: request.method,
                                                 parameterEncoding: parameterEncoding)

        return try! APIManager.shared.performRequest(networkRequest, using: APIManager.JSONObjectArrayResponseSerializer())
    }
}

