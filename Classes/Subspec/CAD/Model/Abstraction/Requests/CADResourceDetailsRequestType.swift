//
//  CADResourceDetailsRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for a resource details request
public protocol CADResourceDetailsRequestType: CodableRequestParameters {

    // MARK: - Request Parameters

    /// The identifier for the resource, could be uuid or callsign, depending on client
    var identifier: String { get }

}
