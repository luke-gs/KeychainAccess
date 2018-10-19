//
//  VehicleFetchParameter.swift
//  MPOL
//
//  Created by RUI WANG on 11/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct VehicleFetchParameter: Requestable {
    public typealias ResultClass = Vehicle

    public let id: String
    public var parameters: [String: Any] {
        return ["id": id]
    }
}
