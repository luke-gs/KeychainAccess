//
//  Entity.swift
//  MPOL
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import MPOLKit

private enum Coding: String {
    case dateCreated = "dateCreated"
    case dateUpdated = "dateUpdated"
    case createdBy = "createdBy"
    case updatedBy = "updatedBy"
    case effectiveDate = "effectiveDate"
    case expiryDate = "expiryDate"
    case entityType = "entityType"
    case isSummary = "isSummary"
    case arn = "arn"
    case jurisdiction = "jurisdiction"
    case source = "source"
    case alertLevel = "alertLevel"
    case associatedAlertLevel = "associatedAlertLevel"
    case actionCount = "actionCount"
    case alerts = "alerts"
    case associatedPersons = "associatedPersons"
    case associatedVehicles = "associatedVehicles"
    case events = "events"
    case addresses = "addresses"
    case media = "media"
    case modelVersion = "modelVersion"
}

@objc(MPLEntity)
open class Entity: MPOLKitEntity {

    override open class var serverTypeRepresentation: String {
        MPLRequiresConcreteImplementation()
    }

    class var localizedDisplayName: String {
        return NSLocalizedString("Entity", comment: "")
    }
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    open var arn: String?
    open var jurisdiction: String?
    
    open var source: MPOLSource?
    open var alertLevel: Alert.Level?
    open var associatedAlertLevel: Alert.Level?
    
    open var actionCount: UInt = 0
    
    open var alerts: [Alert]?
    open var associatedPersons: [Person]?
    open var associatedVehicles: [Vehicle]?
    open var events: [Event]?
    open var addresses: [Address]?
    open var media: [Media]?
    
    // MARK: - Temp properties
    open var lastUpdated: Date? {
        return dateUpdated ?? dateCreated ?? nil
    }

    override public init(id: String) {
        super.init(id: id)
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Entity.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Entity.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Entity.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Entity.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary")
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
        media = unboxer.unbox(key: "media")

        try super.init(unboxer: unboxer)

        alerts = alerts?.filter { $0.level != nil }
        actionCount = unboxer.unbox(key: "actionCount") ?? UInt(alerts?.count ?? 0)
    }

    // MARK: - NSSecureCoding

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.dateUpdated.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: Coding.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: Coding.updatedBy.rawValue) as String?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.expiryDate.rawValue) as Date?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: Coding.entityType.rawValue) as String?
        isSummary = aDecoder.decodeObject(forKey: Coding.isSummary.rawValue) as! Bool?
        arn = aDecoder.decodeObject(of: NSString.self, forKey: Coding.arn.rawValue) as String?
        jurisdiction = aDecoder.decodeObject(of: NSString.self, forKey: Coding.jurisdiction.rawValue) as String?
        actionCount = UInt(truncating: aDecoder.decodeObject(of: NSNumber.self, forKey: Coding.actionCount.rawValue)!)
        alerts = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.alerts.rawValue) as? [Alert]
        associatedPersons = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.associatedPersons.rawValue) as? [Person]
        associatedVehicles = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.associatedVehicles.rawValue) as? [Vehicle]
        events = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.events.rawValue) as? [Event]
        addresses = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.addresses.rawValue) as? [Address]
        media = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.media.rawValue) as? [Media]

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: Coding.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        if aDecoder.containsValue(forKey: Coding.alertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: Coding.alertLevel.rawValue)) {
            alertLevel = level
        }

        if aDecoder.containsValue(forKey: Coding.associatedAlertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: Coding.associatedAlertLevel.rawValue)) {
            associatedAlertLevel = level
        }
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(dateCreated, forKey: Coding.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: Coding.dateUpdated.rawValue)
        aCoder.encode(createdBy, forKey: Coding.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: Coding.updatedBy.rawValue)
        aCoder.encode(effectiveDate, forKey: Coding.effectiveDate.rawValue)
        aCoder.encode(expiryDate, forKey: Coding.expiryDate.rawValue)
        aCoder.encode(entityType, forKey: Coding.entityType.rawValue)
        aCoder.encode(isSummary, forKey: Coding.isSummary.rawValue)
        aCoder.encode(arn, forKey: Coding.arn.rawValue)
        aCoder.encode(jurisdiction, forKey: Coding.jurisdiction.rawValue)
        aCoder.encode(source?.rawValue, forKey: Coding.source.rawValue)
        aCoder.encode(actionCount, forKey: Coding.actionCount.rawValue)
        aCoder.encode(alerts, forKey: Coding.alerts.rawValue)
        aCoder.encode(associatedPersons, forKey: Coding.associatedPersons.rawValue)
        aCoder.encode(associatedVehicles, forKey: Coding.associatedVehicles.rawValue)
        aCoder.encode(events, forKey: Coding.events.rawValue)
        aCoder.encode(addresses, forKey: Coding.addresses.rawValue)
        aCoder.encode(media, forKey: Coding.media.rawValue)
        aCoder.encode(modelVersion, forKey: Coding.modelVersion.rawValue)

        if let alertLevel = alertLevel {
            aCoder.encode(alertLevel.rawValue, forKey: Coding.alertLevel.rawValue)
        }
        
        if let associatedAlertLevel = associatedAlertLevel {
            aCoder.encode(associatedAlertLevel.rawValue, forKey: Coding.associatedAlertLevel.rawValue)
        }
    }
    
    
    // MARK: - Model Versionable
    
    open class var modelVersion: Int {
        return 0
    }
    
    
    // MARK: - Display
    
    // TEMPORARY
//    open func thumbnailImage(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
//        return nil
//    }
    
    open var summary: String {
        return "-"
    }
    
    open var summaryDetail1: String? {
        return "-"
    }
    
    open var summaryDetail2: String? {
        return "-"
    }
    
}
