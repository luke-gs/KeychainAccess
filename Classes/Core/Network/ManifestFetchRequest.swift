//
//  ManifestFetchRequest.swift
//  Alamofire
//
//  Created by Valery Shorinov on 22/11/17.
//

import Foundation
import PromiseKit
import Alamofire

public struct ManifestFetchRequest: Parameterisable {
    
    public typealias ResultClass = [[String:Any]]
    
    /// The type to use for last update
    public enum UpdateType {
        /// A date time string
        case dateTime
        /// Time interval (for backwards compatibility)
        case interval
    }
    
    
    public let parameters: [String: Any]
    public let path: String
    public let method: HTTPMethod
    
    public init(date: Date?, path: String = "manifest/app", parameters: [String: Any] = [:], method: HTTPMethod = .get, updateType: UpdateType = .interval) {
        var path = path
        var parameters = parameters
        
        // Set the date back 60 seconds to account for clock skew
        let date = date?.adding(seconds: -60)
        
        if updateType == .dateTime {
            // Convert date to ISO8601
            if let dateString = ISO8601DateTransformer.shared.reverse(date) {
                // Only use it in the URL if this is a GET request
                if method == .get {
                    path.append("/{dateLastUpdated}")
                }
                parameters["dateLastUpdated"] = dateString
            }
        } else if updateType == .interval {
            // Backwards compatibility to allow use of interval
            if let date = date {
                let interval = Int(date.timeIntervalSince1970)
                parameters["interval"] = String(interval)
            } else {
                parameters["interval"] = "0"
            }
            
            // Only use it in the URL if this is a GET request
            if method == .get {
                path.append("/{interval}")
            }
        }
        
        self.path = path
        self.parameters = parameters
        self.method = method
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

