//
//  CADBookOffRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for book off request
public protocol CADBookOffRequestType: CodableRequestParameters {

    // MARK: - Request Parameters
    var callsign : String { get }

}
