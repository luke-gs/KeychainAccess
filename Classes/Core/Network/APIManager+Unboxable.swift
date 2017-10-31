//
//  APIManager+Unboxable.swift
//  MPOLKit
//
//  Created by Herli Halim on 1/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PromiseKit

// Extension to perform network request that returns anything that conforms to `Unboxable`
public extension APIManager {

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return of specified type.
    public func performRequest<T: Unboxable>(_ networkRequest: NetworkRequestType) throws -> Promise<T> {
        return try performRequest(networkRequest, using: UnboxableResponseSerializer())
    }

    /// Perform specified network request.
    ///
    /// - Parameter networkRequest: The network request to be executed.
    /// - Returns: A promise to return array of specified type.
    public func performRequest<T: Unboxable>(_ networkRequest: NetworkRequestType) throws -> Promise<[T]> {
        return try performRequest(networkRequest, using: UnboxableArrayResponseSerializer())
    }

}
