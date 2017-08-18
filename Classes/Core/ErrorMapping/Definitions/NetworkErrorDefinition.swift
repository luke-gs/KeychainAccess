//
//  NetworkErrorDefinition.swift
//  MPOLKit
//
//  Created by Herli Halim on 16/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkErrorDefinition: ErrorMappable {
    
    typealias SupportedTypeError = APIManagerError

    static public let defaultHTTPStatusCodesMap = [
        400 : (title: "Authentication Failed", message:"The username or password that you entered does not match our records."),
        404 : (title: "Not Found", message: "The resource you tried to access couldn't be found. 😞"),
        500 : (title: "Unknown Error", message: "A unknown error has occurred. 😡"),
    ]

    public let httpStatusCodesMap: [Int: (title: String, message: String)]

    public init(httpStatusCodesMap: [Int: (title: String, message: String)] = NetworkErrorDefinition.defaultHTTPStatusCodesMap) {
        self.httpStatusCodesMap = httpStatusCodesMap
    }

    // MARK: - Error Mappable
    open func mappedError(from error: Error) -> MappedError? {
        if let error = error as? SupportedTypeError {
            if let statusCode = error.response.response?.statusCode,
               let map = httpStatusCodesMap[statusCode] {
                return MappedError(errorDescription: map.message, failureReason:map.title, underlyingError: error)
            }
        }
        return nil
    }
        
    open static var supportedType: Error.Type {
        return SupportedTypeError.self
    }
}
