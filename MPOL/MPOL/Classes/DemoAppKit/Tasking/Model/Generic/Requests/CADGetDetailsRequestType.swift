//
//  CADGetDetailsRequestType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import CoreKit
/// Protocol for a generic get details request, that fetches details based on an identifier
public protocol CADGetDetailsRequestType: CodableRequestParameters {

    // MARK: - Request Parameters

    /// The identifier for the object being fetched, client dependant
    /// This could be uuid or object specific. eg incidentNumber.
    var identifier: String { get }

}
