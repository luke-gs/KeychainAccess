//
//  URLQueryBuilder+Parameterisable.swift
//  MPOLKit
//
//  Created by Herli Halim on 29/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public extension URLQueryBuilder {

    public func urlPathWith(template: String, parameters: Parameterisable) throws -> (path: String, parameters: [String: Any]) {
        return try urlPathWith(template: template, parameters: parameters.parameters)
    }

}
