//
//  Licence.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

@objc(MPLLicence)
open class Licence: DefaultSerialisable {

    // MARK: - Properties

    open var country: String?
    open var createdBy: String?
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var effectiveDate: Date?
    open var entityType: String?
    open var expiryDate: Date?
    open var id: String
    open var isSummary: Bool = false
    open var isSuspended: Bool = false
    open var licenceClasses: [LicenceClass]?
    open var number: String?
    open var remarks: String?
    open var source: MPOLSource?
    open var state: String?
    open var status: String?
    open var statusDescription: String?
    open var statusFromDate: Date?
    open var type: String?
    open var updatedBy: String?

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }

    // MARK: - Unboxable

    fileprivate static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {

        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }

        self.id = id

        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        source = unboxer.unbox(key: "source")

        number = unboxer.unbox(key: "licenceNumber")
        isSuspended = unboxer.unbox(key: "isSuspended") ?? false
        status = unboxer.unbox(key: "status")
        statusDescription = unboxer.unbox(key: "statusDescription")
        statusFromDate = unboxer.unbox(key: "statusFromDate", formatter: Licence.dateTransformer)
        state = unboxer.unbox(key: "state")
        country = unboxer.unbox(key: "country")
        type = unboxer.unbox(key: "licenceType")
        remarks = unboxer.unbox(key: "remarks")

        licenceClasses = unboxer.unbox(key: "classes")

        super.init()
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case country
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case expiryDate
        case id
        case isSummary
        case isSuspended
        case licenceClasses = "classes"
        case number
        case remarks
        case source
        case state
        case status
        case statusDescription
        case statusFromDate
        case type
        case updatedBy
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        try super.init(from: decoder)
        guard !dataMigrated else { return }

        country = try container.decodeIfPresent(String.self, forKey: .country)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        id = try container.decode(String.self, forKey: .id)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        isSuspended = try container.decode(Bool.self, forKey: .isSuspended)
        licenceClasses = try container.decodeIfPresent([LicenceClass].self, forKey: .licenceClasses)
        number = try container.decodeIfPresent(String.self, forKey: .number)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        statusDescription = try container.decodeIfPresent(String.self, forKey: .statusDescription)
        statusFromDate = try container.decodeIfPresent(Date.self, forKey: .statusFromDate)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(country, forKey: CodingKeys.country)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(isSuspended, forKey: CodingKeys.isSuspended)
        try container.encode(licenceClasses, forKey: CodingKeys.licenceClasses)
        try container.encode(number, forKey: CodingKeys.number)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(state, forKey: CodingKeys.state)
        try container.encode(status, forKey: CodingKeys.status)
        try container.encode(statusDescription, forKey: CodingKeys.statusDescription)
        try container.encode(statusFromDate, forKey: CodingKeys.statusFromDate)
        try container.encode(type, forKey: CodingKeys.type)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
    }
}

/// Licence Class
extension Licence {
    @objc(MPLLicenceClass)
    public class LicenceClass: DefaultSerialisable {

        open var classDescription: String?
        open var code: String?
        open var conditions: [Condition]?
        open var createdBy: String?
        open var dateCreated: Date?
        open var dateUpdated: Date?
        open var effectiveDate: Date?
        open var entityType: String?
        open var expiryDate: Date?
        open var id: String
        open var isSummary: Bool = false
        open var name: String?
        open var proficiency: String?
        open var source: MPOLSource?
        open var updatedBy: String?

        public required init(id: String) {
            self.id = id
            super.init()
        }

        public required init(unboxer: Unboxer) throws {

            guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
            }

            self.id = id

            dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
            dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
            createdBy = unboxer.unbox(key: "createdBy")
            updatedBy = unboxer.unbox(key: "updatedBy")
            effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
            expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
            entityType = unboxer.unbox(key: "entityType")
            isSummary = unboxer.unbox(key: "isSummary") ?? false
            source = unboxer.unbox(key: "source")

            code = unboxer.unbox(key: "code")
            name = unboxer.unbox(key: "name")
            proficiency = unboxer.unbox(key: "proficiency")
            classDescription = unboxer.unbox(key: "description")
            conditions = unboxer.unbox(key: "conditions")

            super.init()
        }

        // MARK: - Codable

        private enum CodingKeys: String, CodingKey {
            case classDescription
            case code
            case conditions
            case createdBy
            case dateCreated
            case dateUpdated
            case effectiveDate
            case entityType
            case expiryDate
            case id
            case isSummary
            case name
            case proficiency
            case source
            case updatedBy
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)

            try super.init(from: decoder)
            guard !dataMigrated else { return }

            classDescription = try container.decodeIfPresent(String.self, forKey: .classDescription)
            code = try container.decodeIfPresent(String.self, forKey: .code)
            conditions = try container.decodeIfPresent([Condition].self, forKey: .conditions)
            createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
            dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
            dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
            effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
            entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
            expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
            id = try container.decode(String.self, forKey: .id)
            isSummary = try container.decode(Bool.self, forKey: .isSummary)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            proficiency = try container.decodeIfPresent(String.self, forKey: .proficiency)
            source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
            updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        }

        open override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(classDescription, forKey: CodingKeys.classDescription)
            try container.encode(code, forKey: CodingKeys.code)
            try container.encode(conditions, forKey: CodingKeys.conditions)
            try container.encode(createdBy, forKey: CodingKeys.createdBy)
            try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
            try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
            try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
            try container.encode(entityType, forKey: CodingKeys.entityType)
            try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
            try container.encode(id, forKey: CodingKeys.id)
            try container.encode(isSummary, forKey: CodingKeys.isSummary)
            try container.encode(name, forKey: CodingKeys.name)
            try container.encode(proficiency, forKey: CodingKeys.proficiency)
            try container.encode(source, forKey: CodingKeys.source)
            try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        }
    }

    /// Licence Condition
    @objc(MPLCondition)
    public class Condition: DefaultSerialisable {

        open var condition: String?
        open var createdBy: String?
        open var dateCreated: Date?
        open var dateUpdated: Date?
        open var effectiveDate: Date?
        open var entityType: String?
        open var expiryDate: Date?
        open var id: String
        open var isSummary: Bool = false
        open var source: MPOLSource?
        open var updatedBy: String?

        public required init(id: String) {
            self.id = id
            super.init()
        }

        public required init(unboxer: Unboxer) throws {

            guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
            }

            self.id = id

            dateCreated = unboxer.unbox(key: "dateCreated", formatter: Licence.dateTransformer)
            dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Licence.dateTransformer)
            createdBy = unboxer.unbox(key: "createdBy")
            updatedBy = unboxer.unbox(key: "updatedBy")
            effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
            expiryDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
            entityType = unboxer.unbox(key: "entityType")
            isSummary = unboxer.unbox(key: "isSummary") ?? false
            source = unboxer.unbox(key: "source")

            condition = unboxer.unbox(key: "condition")

            super.init()
        }

        func displayValue() -> String? {
            var value = ""

            if let condition = self.condition {
                value += condition
            }

            if let fromDate = dateUpdated, let toDate = expiryDate {
                value += " - valid from: \(fromDate.wrap(dateFormatter: DateFormatter.preferredDateStyle)) to \(toDate.wrap(dateFormatter: DateFormatter.preferredDateStyle))"
            }

            return value
        }

        // MARK: - Codable

        private enum CodingKeys: String, CodingKey {
            case condition
            case createdBy
            case dateCreated
            case dateUpdated
            case effectiveDate
            case entityType
            case expiryDate
            case id
            case isSummary
            case source
            case updatedBy
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)

            try super.init(from: decoder)
            guard !dataMigrated else { return }

            condition = try container.decodeIfPresent(String.self, forKey: .condition)
            createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
            dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
            dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
            effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
            entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
            expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
            id = try container.decode(String.self, forKey: .id)
            isSummary = try container.decode(Bool.self, forKey: .isSummary)
            source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
            updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        }

        open override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(condition, forKey: CodingKeys.condition)
            try container.encode(createdBy, forKey: CodingKeys.createdBy)
            try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
            try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
            try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
            try container.encode(entityType, forKey: CodingKeys.entityType)
            try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
            try container.encode(id, forKey: CodingKeys.id)
            try container.encode(isSummary, forKey: CodingKeys.isSummary)
            try container.encode(source, forKey: CodingKeys.source)
            try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        }

    }

}
