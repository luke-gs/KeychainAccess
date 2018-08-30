//
//  APIManagerError.swift
//  Alamofire
//
//  Created by Herli Halim on 8/8/17.
//

import Foundation
import Alamofire

public struct APIManagerError: Error {
    public let underlyingError: Error
    public let response: DefaultDataResponse

    public init(underlyingError: Error, response: DefaultDataResponse) {
        self.underlyingError = underlyingError
        self.response = response
    }
}

// MARK: CustomNSError Implementations
public let MPLDataResponseKey = "MPLDataResponseKey"

extension APIManagerError: CustomNSError {
    public var errorUserInfo: [String : Any] {
        return [NSUnderlyingErrorKey: underlyingError, MPLDataResponseKey: response]
    }
}

// MARK: LocalizedError Implementations
extension APIManagerError: LocalizedError {
    public var errorDescription: String? {
        return underlyingError.localizedDescription
    }
}
