//
//  Entity.swift
//  MPOL
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox
import MPOLKit

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
        
        
        if let actionCount: UInt = unboxer.unbox(key: "actionCount") {
            self.actionCount = actionCount
        }
        

        
        try super.init(unboxer: unboxer)
    }

    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {

        if aDecoder.containsValue(forKey: CodingKey.alertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.alertLevel.rawValue)) {
            alertLevel = level
        }
        if aDecoder.containsValue(forKey: CodingKey.associatedAlertLevel.rawValue), let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.associatedAlertLevel.rawValue)) {
            associatedAlertLevel = level
        }
        
        super.init(coder: aDecoder)
    }

    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)

        if let alertLevel = alertLevel {
            aCoder.encode(alertLevel.rawValue, forKey: CodingKey.alertLevel.rawValue)
        }
        
        if let associatedAlertLevel = associatedAlertLevel {
            aCoder.encode(associatedAlertLevel.rawValue, forKey: CodingKey.associatedAlertLevel.rawValue)
        }

        super.encode(with: aCoder)
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
        return "MM"
    }
    
    open var summaryDetail2: String? {
        return "GG"
    }
    
}

private enum CodingKey: String {
    case version
    case alertLevel
    case associatedAlertLevel
}
