//
//  Alias.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLAlias)
open class Alias: IdentifiableDataModel {

    // MARK: - Properties

    open var createdBy: String?
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var effectiveDate: Date?
    open var entityType: String?
    open var expiryDate: Date?
    open var isSummary: Bool = false
    open var jurisdiction: String?
    open var source: MPOLSource?
    open var type: String?
    open var updatedBy: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Alias.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Alias.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alias.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Alias.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        type = unboxer.unbox(key: "nameType")
        jurisdiction = unboxer.unbox(key: "jurisdiction")

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case expiryDate
        case isSummary
        case jurisdiction
        case source
        case type
        case updatedBy
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
    }
}
