//
//  NetworkRequest.swift
//  MPOLKit
//
//  Created by Herli Halim on 29/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

public struct NetworkRequest: NetworkRequestType {

    public let path: String
    public let parameters: [String: Any]?
    public let method: HTTPMethod
    public let parameterEncoding: ParameterEncoding
    public let headers: [String : String]?

    private static var queryBuilder = URLQueryBuilder()

    public init(pathTemplate: String, parameters: [String: Any], method: HTTPMethod = .get, parameterEncoding: ParameterEncoding = URLEncoding.default, headers: [String : String]? = nil) throws {

        self.method = method
        self.headers = headers

        let info = try NetworkRequest.queryBuilder.urlPathWith(template: pathTemplate, parameters: parameters)

        self.path = info.path
        self.parameters = info.parameters
        self.parameterEncoding = parameterEncoding
    }

}
