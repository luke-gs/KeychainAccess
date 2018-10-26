//
//  Contact.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

@objc(MPLContact)
open class Contact: DefaultSerialisable {

    public enum ContactType: String, UnboxableEnum, Codable {
        case phone = "home"
        case mobile = "mobile"
        case email = "email"

        public func localizedDescription() -> String {
            switch self {
            case .phone: return "Phone"
            case .mobile: return "Mobile"
            case .email: return "Email"
            }
        }
    }

    // MARK: - Properties

    open var createdBy: String?
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var effectiveDate: Date?
    open var entityType: String?
    open var expiryDate: Date?
    open var id: String
    open var isSummary: Bool = false
    open var jurisdiction: String?
    open var source: MPOLSource?
    open var subType: String?
    open var type: Contact.ContactType?
    open var updatedBy: String?
    open var value: String?

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(id: String = UUID().uuidString) {
        self.id = id
        self.isSummary = false

        super.init()
    }

    public required init(unboxer: Unboxer) throws {

        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }

        self.id = id

        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Contact.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Contact.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Contact.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Contact.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        type = unboxer.unbox(key: "type")
        subType = unboxer.unbox(key: "contactSubType")
        value = unboxer.unbox(key: "value")
        jurisdiction = unboxer.unbox(key: "jurisdiction")
        super.init()
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case expiryDate
        case id
        case isSummary
        case jurisdiction
        case source
        case subType
        case type
        case updatedBy
        case value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        try super.init(from: decoder)
        guard !dataMigrated else { return }

        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        id = try container.decode(String.self, forKey: .id)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        subType = try container.decodeIfPresent(String.self, forKey: .subType)
        type = try container.decodeIfPresent(Contact.ContactType.self, forKey: .type)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        value = try container.decodeIfPresent(String.self, forKey: .value)
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
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(subType, forKey: CodingKeys.subType)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        try container.encode(value, forKey: CodingKeys.value)
    }

}
