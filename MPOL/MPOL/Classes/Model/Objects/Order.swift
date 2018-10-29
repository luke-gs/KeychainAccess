//
//  Order.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLOrder)
open class Order: Entity {

    // MARK: - Properties

    public var issuedDate: Date?
    public var issuingAuthority: String?
    public var orderDescription: String?
    public var status: String?
    public var type: String?

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        status = unboxer.unbox(key: CodingKeys.status.rawValue)
        issuingAuthority = unboxer.unbox(key: CodingKeys.issuingAuthority.rawValue)
        orderDescription = unboxer.unbox(key: CodingKeys.orderDescription.rawValue)
        issuedDate = unboxer.unbox(key: CodingKeys.issuedDate.rawValue, formatter: ISO8601DateTransformer.shared)

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case issuedDate = "dateIssued"
        case issuingAuthority
        case orderDescription = "description"
        case status
        case type
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        issuedDate = try container.decodeIfPresent(Date.self, forKey: .issuedDate)
        issuingAuthority = try container.decodeIfPresent(String.self, forKey: .issuingAuthority)
        orderDescription = try container.decodeIfPresent(String.self, forKey: .orderDescription)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(issuedDate, forKey: CodingKeys.issuedDate)
        try container.encode(issuingAuthority, forKey: CodingKeys.issuingAuthority)
        try container.encode(orderDescription, forKey: CodingKeys.orderDescription)
        try container.encode(status, forKey: CodingKeys.status)
        try container.encode(type, forKey: CodingKeys.type)
    }
}
