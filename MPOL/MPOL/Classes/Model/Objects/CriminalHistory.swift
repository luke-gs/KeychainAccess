//
//  CriminalHistory.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc (MPLCrimimalHistory)
open class CriminalHistory: Entity {

    // MARK: - Properties

    public var courtName: String?
    public var occurredDate: Date?
    public var offenceDescription: String?
    public var primaryCharge: String?

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        offenceDescription = unboxer.unbox(key: CodingKeys.offenceDescription.rawValue)
        primaryCharge = unboxer.unbox(key: CodingKeys.primaryCharge.rawValue)
        occurredDate = unboxer.unbox(key: CodingKeys.occurredDate.rawValue, formatter: ISO8601DateTransformer.shared)
        courtName = unboxer.unbox(key: CodingKeys.courtName.rawValue)

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case courtName
        case occurredDate = "occurred"
        case offenceDescription = "description"
        case primaryCharge
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        courtName = try container.decodeIfPresent(String.self, forKey: .courtName)
        occurredDate = try container.decodeIfPresent(Date.self, forKey: .occurredDate)
        offenceDescription = try container.decodeIfPresent(String.self, forKey: .offenceDescription)
        primaryCharge = try container.decodeIfPresent(String.self, forKey: .primaryCharge)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(courtName, forKey: CodingKeys.courtName)
        try container.encode(occurredDate, forKey: CodingKeys.occurredDate)
        try container.encode(offenceDescription, forKey: CodingKeys.offenceDescription)
        try container.encode(primaryCharge, forKey: CodingKeys.primaryCharge)
    }

}

open class OffenderCharge: CriminalHistory {
    let nextCourtDate: Date?

    public required init(unboxer: Unboxer) throws {
        nextCourtDate = unboxer.unbox(key: CodingKeys.nextCourtDate.rawValue, formatter: ISO8601DateTransformer.shared)
        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case nextCourtDate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nextCourtDate = try container.decodeIfPresent(Date.self, forKey: .nextCourtDate)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nextCourtDate, forKey: CodingKeys.nextCourtDate)
    }
}

open class OffenderConviction: CriminalHistory {
    let finalCourtDate: Date?

    public required init(unboxer: Unboxer) throws {
        finalCourtDate = unboxer.unbox(key: CodingKeys.finalCourtDate.rawValue, formatter: ISO8601DateTransformer.shared)
        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case finalCourtDate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        finalCourtDate = try container.decodeIfPresent(Date.self, forKey: .finalCourtDate)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(finalCourtDate, forKey: CodingKeys.finalCourtDate)
    }
}
