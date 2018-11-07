//
//  Entity.swift
//  MPOL
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import PublicSafetyKit

@objc(MPLEntity)
open class Entity: MPOLKitEntity {

    // MARK: - Class

    class var localizedDisplayName: String {
        return NSLocalizedString("Entity", comment: "")
    }

    // MARK: - Properties

    public var actionCount: UInt = 0
    public var addresses: [Address]?
    public var alertLevel: Alert.Level?
    public var alerts: [Alert]?
    public var arn: String?
    public var associatedAlertLevel: Alert.Level?
    public var associatedPersons: [Person]?
    public var associatedReasons: [AssociationReason]?
    public var associatedVehicles: [Vehicle]?
    public var createdBy: String?
    public var dateCreated: Date?
    public var dateUpdated: Date?
    public var effectiveDate: Date?
    public var entityType: String?
    public var events: [RetrievedEvent]?
    public var expiryDate: Date?
    public var externalIdentifiers: [MPOLSource: String]?
    public var isSummary: Bool = false
    public var jurisdiction: String?
    public var media: [Media]?
    public var source: MPOLSource?
    public var updatedBy: String?

    // MARK: - Calculated

    open override var uuid: String {
        // Use the server type, source and id for a unique identifier
        return [type(of: self).serverTypeRepresentation, source?.rawValue, id].joined()
    }

    public var lastUpdated: Date? {
        return dateUpdated ?? dateCreated ?? nil
    }

    public var summary: String {
        return "-"
    }

    public var summaryDetail1: String? {
        return "-"
    }

    public var summaryDetail2: String? {
        return "-"
    }

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {

        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Entity.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Entity.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Entity.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Entity.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary") ?? false
        arn = unboxer.unbox(key: "arn")
        jurisdiction = unboxer.unbox(key: "jurisdiction")

        source = unboxer.unbox(key: "source")
        alertLevel = unboxer.unbox(key: "alertLevel")
        associatedAlertLevel = unboxer.unbox(key: "associatedAlertLevel")

        alerts = unboxer.unbox(key: "alerts")
        associatedPersons = unboxer.unbox(key: "persons")
        associatedVehicles = unboxer.unbox(key: "vehicles")
        events = unboxer.unbox(key: "events")
        addresses = unboxer.unbox(key: "locations")
        media = unboxer.unbox(key: "mediaItems")
        associatedReasons = unboxer.unbox(key: "associationReasons")

        externalIdentifiers = unboxer.unbox(key: "externalIdentifiers")
        alerts = alerts?.filter { $0.level != nil }

        try super.init(unboxer: unboxer)

        actionCount = unboxer.unbox(key: "actionCount") ?? UInt(alerts?.count ?? 0)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case actionCount
        case addresses
        case alertLevel
        case alerts
        case arn
        case associatedAlertLevel
        case associatedPersons
        case associatedReasons
        case associatedVehicles
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case events
        case expiryDate
        case externalIdentifiers
        case isSummary
        case jurisdiction
        case media
        case source
        case updatedBy
        case version
    }

    public override init(id: String) {
        super.init(id: id)
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        actionCount = try container.decode(UInt.self, forKey: .actionCount)
        addresses = try container.decodeIfPresent([Address].self, forKey: .addresses)
        alertLevel = try container.decodeIfPresent(Alert.Level.self, forKey: .alertLevel)
        alerts = try container.decodeIfPresent([Alert].self, forKey: .alerts)
        arn = try container.decodeIfPresent(String.self, forKey: .arn)
        associatedAlertLevel = try container.decodeIfPresent(Alert.Level.self, forKey: .associatedAlertLevel)
        associatedPersons = try container.decodeIfPresent([Person].self, forKey: .associatedPersons)
        associatedReasons = try container.decodeIfPresent([AssociationReason].self, forKey: .associatedReasons)
        associatedVehicles = try container.decodeIfPresent([Vehicle].self, forKey: .associatedVehicles)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        events = try container.decodeIfPresent([RetrievedEvent].self, forKey: .events)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        externalIdentifiers = try container.decodeIfPresent([MPOLSource: String].self, forKey: .externalIdentifiers)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        jurisdiction = try container.decodeIfPresent(String.self, forKey: .jurisdiction)
        media = try container.decodeIfPresent([Media].self, forKey: .media)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actionCount, forKey: CodingKeys.actionCount)
        try container.encode(addresses, forKey: CodingKeys.addresses)
        try container.encode(alertLevel, forKey: CodingKeys.alertLevel)
        try container.encode(alerts, forKey: CodingKeys.alerts)
        try container.encode(arn, forKey: CodingKeys.arn)
        try container.encode(associatedAlertLevel, forKey: CodingKeys.associatedAlertLevel)
        try container.encode(associatedPersons, forKey: CodingKeys.associatedPersons)
        try container.encode(associatedReasons, forKey: CodingKeys.associatedReasons)
        try container.encode(associatedVehicles, forKey: CodingKeys.associatedVehicles)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(events, forKey: CodingKeys.events)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(externalIdentifiers, forKey: CodingKeys.externalIdentifiers)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(jurisdiction, forKey: CodingKeys.jurisdiction)
        try container.encode(media, forKey: CodingKeys.media)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
    }

    // MARK: - Methods

    open override func isEqual(_ object: Any?) -> Bool {
        guard let otherEntity = object as? Entity else {
            return false
        }
        return self.uuid == otherEntity.uuid
    }
}
