//
//  CADEmployeeDetailsRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol for employee details request
public protocol CADEmployeeDetailsRequestType: CodableRequestParameters {

    // MARK: - Request Parameters

    /// The identifier for this incident, could be uuid or employeeNumber, depending on client
    var identifier: String { get }

}
