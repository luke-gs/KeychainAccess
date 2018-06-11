//
//  CADEmployeeDetailsRequestCore.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of book off request
open class CADEmployeeDetailsRequestCore: CADEmployeeDetailsRequestType {

    public init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: - Request Parameters

    /// The employee number to search
    open var identifier: String

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case identifier
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: CodingKeys.identifier)
    }
}

