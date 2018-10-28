//
//  TrafficHistory.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLTrafficHistory)
public class TrafficHistory: DefaultModel {

    // MARK: - Properties

    public var demeritPoint: Int = 0
    public var expiryDate: Date?
    public var isLicenceCancelled: Bool = false
    public var isLicenceSurrendered: Bool = false
    public var issuedDate: Date?
    public var name: String?
    public var occurredDate: Date?
    public var source: MPOLSource!
    public var trafficHistoryDescription: String?

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        source = unboxer.unbox(key: CodingKeys.source.rawValue)
        trafficHistoryDescription = unboxer.unbox(key: CodingKeys.trafficHistoryDescription.rawValue)
        isLicenceCancelled = try unboxer.unbox(key: CodingKeys.isLicenceCancelled.rawValue)
        isLicenceSurrendered = try unboxer.unbox(key: CodingKeys.isLicenceSurrendered.rawValue)
        demeritPoint = try unboxer.unbox(key: CodingKeys.demeritPoint.rawValue)
        name = unboxer.unbox(key: CodingKeys.name.rawValue)

        occurredDate = unboxer.unbox(key: CodingKeys.occurredDate.rawValue, formatter: ISO8601DateTransformer.shared)
        expiryDate = unboxer.unbox(key: CodingKeys.expiryDate.rawValue, formatter: ISO8601DateTransformer.shared)
        issuedDate = unboxer.unbox(key: CodingKeys.issuedDate.rawValue, formatter: ISO8601DateTransformer.shared)

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case demeritPoint
        case expiryDate
        case isLicenceCancelled = "licenceCancelled"
        case isLicenceSurrendered = "licenceSurrendered"
        case issuedDate = "dateIssued"
        case name
        case occurredDate = "occurred"
        case source
        case trafficHistoryDescription = "description"
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        demeritPoint = try container.decode(Int.self, forKey: .demeritPoint)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        isLicenceCancelled = try container.decode(Bool.self, forKey: .isLicenceCancelled)
        isLicenceSurrendered = try container.decode(Bool.self, forKey: .isLicenceSurrendered)
        issuedDate = try container.decodeIfPresent(Date.self, forKey: .issuedDate)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        occurredDate = try container.decodeIfPresent(Date.self, forKey: .occurredDate)
        source = try container.decode(MPOLSource.self, forKey: .source)
        trafficHistoryDescription = try container.decodeIfPresent(String.self, forKey: .trafficHistoryDescription)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(demeritPoint, forKey: CodingKeys.demeritPoint)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(isLicenceCancelled, forKey: CodingKeys.isLicenceCancelled)
        try container.encode(isLicenceSurrendered, forKey: CodingKeys.isLicenceSurrendered)
        try container.encode(issuedDate, forKey: CodingKeys.issuedDate)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(occurredDate, forKey: CodingKeys.occurredDate)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(trafficHistoryDescription, forKey: CodingKeys.trafficHistoryDescription)
    }

}
