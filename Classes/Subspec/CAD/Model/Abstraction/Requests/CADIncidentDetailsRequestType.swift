//
//  CADIncidentDetailsRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for an incident details request
public protocol CADIncidentDetailsRequestType: CodableRequestParameters {

    // MARK: - Request Parameters

    /// The identifier for the employee, could be uuid or incidentNumber, depending on client
    var identifier: String { get }

}
