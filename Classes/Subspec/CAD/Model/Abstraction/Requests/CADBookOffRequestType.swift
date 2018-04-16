//
//  CADBookOffRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for book off request
public protocol CADBookOffRequestType: CodableRequest {

    // MARK: - Request Parameters
    var callsign : String! { get }

}

// MARK: - API Manager method for sending request
public extension APIManager {

    /// Book off from CAD
    public func cadBookOff(with request: CADBookOffRequestType) -> Promise<Void> {
        return performRequest(request, method: .put)
    }
}
