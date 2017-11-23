//
//  ManifestFetchRequest.swift
//  Alamofire
//
//  Created by Valery Shorinov on 22/11/17.
//

import Foundation
import PromiseKit

public struct ManifestFetchRequest: Parameterisable {
    public typealias ResultClass = [[String:Any]]
    
    let path: String
    
    public private(set) var parameters: [String: Any]
    
    init(date: Date?) {
        
        var path:String = "manifest/app"
        var parameters:[String:Any] = [:]
        if let date = date?.addingTimeInterval(-60.0) {
            let interval = Int(date.timeIntervalSince1970)
            path.append("/{interval}")
            parameters["interval"] = String(interval)
        } else {
            path.append("/{interval}")
            parameters["interval"] = "0"
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

