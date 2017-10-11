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
    var plugins: [PluginType]? { get }
    var errorMapper: ErrorMapper? { get }
    var trustPolicyManager: ServerTrustPolicyManager? { get }

}

public struct APIManagerDefaultConfiguration: APIManagerConfigurable {
    
    public let url: URLConvertible
    public let urlSessionConfiguration: URLSessionConfiguration
    public let plugins: [PluginType]?
    public let errorMapper: ErrorMapper?
    public let trustPolicyManager: ServerTrustPolicyManager?

    public init(url: URLConvertible,
                urlSessionConfiguration: URLSessionConfiguration = APIManagerDefaultConfiguration.defaultConfiguration(),
                plugins: [PluginType]? = nil,
                errorMapper: ErrorMapper? = APIManagerDefaultConfiguration.defaultErrorMapper(),
                trustPolicyManager: ServerTrustPolicyManager? = nil) {

        self.url = url
        self.urlSessionConfiguration = urlSessionConfiguration
        self.plugins = plugins
        self.errorMapper = errorMapper
        self.trustPolicyManager = trustPolicyManager
    }
}

// The default values static methods.
extension APIManagerDefaultConfiguration {

    public static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return config
    }

    public static func defaultErrorMapper() -> ErrorMapper {
        let mapper = ErrorMapper(definitions: [NetworkErrorDefinition()])
        return mapper
    }
    
}
