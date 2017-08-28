//
//  APIManagerConfigurable.swift
//  MPOLKit
//
//  Created by Herli Halim on 7/6/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire
import Unbox

// MARK: API Configuration
public protocol APIManagerConfigurable {

    var url: URLConvertible { get }

    var urlSessionConfiguration: URLSessionConfiguration { get }
    var errorMapper: ErrorMapper? { get }
    var trustPolicyManager: ServerTrustPolicyManager? { get }
}

public struct APIManagerDefaultConfiguration<S: EntitySource>: APIManagerConfigurable {
    
    public let url: URLConvertible
    public let urlSessionConfiguration: URLSessionConfiguration
    public let errorMapper: ErrorMapper?
    public let trustPolicyManager: ServerTrustPolicyManager?

    static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return config
    }

    static func defaultErrorMapper() -> ErrorMapper {
        let mapper = ErrorMapper(definitions: [NetworkErrorDefinition()])
        return mapper
    }
    
    public init(url: URLConvertible, urlSessionConfiguration: URLSessionConfiguration = APIManagerDefaultConfiguration.defaultConfiguration(), errorMapper: ErrorMapper? = APIManagerDefaultConfiguration.defaultErrorMapper(), trustPolicyManager: ServerTrustPolicyManager? = nil) {
        self.url = url
        self.urlSessionConfiguration = urlSessionConfiguration
        self.errorMapper = errorMapper
        self.trustPolicyManager = trustPolicyManager
    }
}
