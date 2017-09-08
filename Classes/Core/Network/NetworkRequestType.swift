//
//  NetworkRequestType.swift
//  MPOLKit
//
//  Created by Herli Halim on 29/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkRequestType {

    var path: String { get }

    var method: HTTPMethod { get }

    var parameters: [String: Any]? { get }

    // Any additional headers if required.
    var headers: [String : String]? { get }

    var parameterEncoding: ParameterEncoding { get }

}
