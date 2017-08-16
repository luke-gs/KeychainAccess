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
    
    public var httpStatusCodesMessageMapping = [
        400 : "The credentials you have entered are invalid. Please try again, or contact the service desk.",
        404 : "The resource you tried to access couldn't be found. 😞",
        500 : "FISH does not like this. 😡🖕🏿",
    ]
    
    typealias SupportedTypeError = APIManagerError
    
    // MARK: - Error Mappable
    open func mappedError(from error: Error) -> MappedError? {
        if let error = error as? SupportedTypeError {
            
            if let statusCode = error.response.response?.statusCode,
               let errorDescription = httpStatusCodesMessageMapping[statusCode] {
                return MappedError(errorDescription: errorDescription, underlyingError: error)
            }
        }
        return nil
    }
        
    open static var supportedType: Error.Type {
        return SupportedTypeError.self
    }
}
