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
    var employeeNumber : String { get }

}
