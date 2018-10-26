//
//  AssociationReason.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import Unbox

@objc(MPLAssociationReason)
open class AssociationReason: DefaultSerialisable {

    // MARK: - Properties

    open var effectiveDate: Date?
    open var id: String
    open var reason: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: AssociationReason.dateTransformer)
        reason = unboxer.unbox(key: "reason")

        super.init()
    }

    // MARK: - Methods

    func formattedReason() -> String? {
        guard let reason = reason else { return nil }
        guard let date = effectiveDate else { return reason }
        return reason + " " +  DateFormatter.preferredDateStyle.string(from: date)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case effectiveDate
        case id
        case reason
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        try super.init(from: decoder)
        guard !dataMigrated else { return }

        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        reason = try container.decodeIfPresent(String.self, forKey: .reason)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(reason, forKey: CodingKeys.reason)
    }

}
