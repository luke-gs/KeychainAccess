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
        400 : (title: "Bad credentials", message: "The username and password entered are not valid. Please check your details and enter again."),
        401 : (title: "Unauthorised", message: "The credential has expired. Please try to login again."),
        404 : (title: "The thing you try to get to doesn’t exist", message: "This link is not currently working. Please try again or contact your Help Desk for support."),
        504 : (title: "Network timed out", message: "This request has timed out. Please confirm you have a network connection and try again."),
        500 : (title: "Unknown Error", message: "The server has experienced an error. Please try again or contact your Help Desk for support."),
        503 : (title: "Timed out", message: "This request has timed out. Please confirm you have a network connection and try again.")
    ]

    /// Handle system error codes
    static public let defaultSystemDomainCodesMap = [
        NSURLErrorNotConnectedToInternet : (title: "No network connection", message:"You do not currently have a network connection."),
        NSURLErrorTimedOut : (title: "Timed out", message: "This request has timed out. Please confirm you have a network connection and try again.")
    ]

    public let systemErrorCodesMap: [Int: (title: String, message: String)]
    public let httpStatusCodesMap: [Int: (title: String, message: String)]


    public init(httpStatusCodesMap: [Int: (title: String, message: String)] = NetworkErrorDefinition.defaultHTTPStatusCodesMap,
                systemErrorCodesMap: [Int: (title: String, message: String)] = NetworkErrorDefinition.defaultSystemDomainCodesMap) {
        self.httpStatusCodesMap = httpStatusCodesMap
        self.systemErrorCodesMap = systemErrorCodesMap
    }

    // MARK: - Error Mappable
    open func mappedError(from error: Error) -> MappedError? {
        if let error = error as? SupportedTypeError {
            if let statusCode = error.response.response?.statusCode,
                let map = httpStatusCodesMap[statusCode] {
                return MappedError(errorDescription: map.message, failureReason:map.title, underlyingError: error)
            } else if let systemError = error.response.error as NSError?,
                let map = systemErrorCodesMap[systemError.code] {
                return MappedError(errorDescription: map.message, failureReason: map.title, underlyingError: systemError)
            }
        }
        return nil
    }

    open static var supportedType: Error.Type {
        return SupportedTypeError.self
    }
}
