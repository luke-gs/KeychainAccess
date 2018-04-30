//
//  ManifestFetchRequest.swift
//  Alamofire
//
//  Created by Valery Shorinov on 22/11/17.
//

import Foundation
import PromiseKit

public struct ManifestFetchRequest: Parameterisable {
    
    /// The type to use for last update
    public enum UpdateType {
        /// Time interval
        case interval
        /// A date time string
        case dateTime
    }
    
    public typealias ResultClass = [[String:Any]]
    
    let path: String
    
    public private(set) var parameters: [String: Any]
    
    public init(date: Date?, path: String = "manifest/app", parameters: [String: Any] = [:], updateType: UpdateType = .interval) {
        var path = path
        
        var parameters = parameters
        
        if updateType == .interval {
            path.append("/{interval}")
            
            if let date = date?.addingTimeInterval(-60.0) {
                let interval = Int(date.timeIntervalSince1970)
                parameters["interval"] = String(interval)
            } else {
                parameters["interval"] = "0"
            }
        } else if updateType == .dateTime {
            if let dateString = ISO8601DateTransformer.shared.reverse(date) {
                path.append("/{dateLastUpdated}")
                parameters["dateLastUpdated"] = dateString 
            }
        }
        
        self.path = path
        self.parameters = parameters
    }
}

public extension APIManager {
    
    func fetchManifest(with request: ManifestFetchRequest) -> Promise<ManifestFetchRequest.ResultClass> {
        let networkRequest = try! NetworkRequest(pathTemplate: request.path, parameters: request.parameters)

        return try! APIManager.shared.performRequest(networkRequest, using: APIManager.JSONObjectArrayResponseSerializer())
    }
}

