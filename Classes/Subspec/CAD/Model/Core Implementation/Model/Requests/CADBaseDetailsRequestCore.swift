//
//  CADBaseDetailsRequestCore.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore base implementation for a details request based on an identifier
open class CADBaseDetailsRequestCore: Codable {

    public init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: - Request Parameters

    /// The identifier used for the object, depending on client
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
