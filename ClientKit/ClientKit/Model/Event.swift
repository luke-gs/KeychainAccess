//
//  Event.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import Foundation
import MPOLKit
import Unbox

open class Event: MPOLKitEntity {

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    override open class var serverTypeRepresentation: String {
        return "event"
    }

    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool = false
    open var arn: String?
    open var jurisdiction: String?
    
    
    open var source: MPOLSource?
    open var alertLevel: Alert.Level?
    open var associatedAlertLevel: Alert.Level?
    
    open var alerts: [Alert]?
    open var associatedPersons: [Person]?
    open var associatedVehicles: [Vehicle]?
    open var events: [Event]?
    open var addresses: [Address]?
    open var media: [Media]?
    
    open var eventType: String?
    open var name: String?
    open var title: String?
    open var eventDescription: String?
    open var status: String?
    open var occurredDate: Date?
    

    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Event.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Event.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Event.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Event.dateTransformer)
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
        media = unboxer.unbox(key: "media")
        
        eventType = unboxer.unbox(key: "eventType")
        name = unboxer.unbox(key: "name")
        title = unboxer.unbox(key: "title")
        eventDescription = unboxer.unbox(key: "description")
        status = unboxer.unbox(key: "status")
        occurredDate = unboxer.unbox(key: "occurred", formatter: Event.dateTransformer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)

        arn = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.arn.rawValue) as String?
        jurisdiction = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.jurisdiction.rawValue) as String?

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        if aDecoder.containsValue(forKey: CodingKey.alertLevel.rawValue),
            let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.alertLevel.rawValue)) {
            alertLevel = level
        }

        if aDecoder.containsValue(forKey: CodingKey.associatedAlertLevel.rawValue),
            let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.associatedAlertLevel.rawValue)) {
            associatedAlertLevel = level
        }

        alerts = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.alerts.rawValue) as? [Alert]
        associatedPersons = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.associatedPersons.rawValue) as? [Person]
        associatedVehicles = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.associatedVehicles.rawValue) as? [Vehicle]
        events = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.events.rawValue) as? [Event]
        addresses = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.addresses.rawValue) as? [Address]
        media = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.media.rawValue) as? [Media]

        eventType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.eventType.rawValue) as String?
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.name.rawValue) as String?
        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
        eventDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.eventDescription.rawValue) as String?
        occurredDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.occurredDate.rawValue) as Date?
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(arn, forKey: CodingKey.arn.rawValue)
        aCoder.encode(jurisdiction, forKey: CodingKey.jurisdiction.rawValue)

        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        if let level = alertLevel?.rawValue {
            aCoder.encode(level, forKey: CodingKey.alertLevel.rawValue)
        }

        if let level = associatedAlertLevel?.rawValue {
            aCoder.encode(level, forKey: CodingKey.associatedAlertLevel.rawValue)
        }

        aCoder.encode(alerts, forKey: CodingKey.alerts.rawValue)
        aCoder.encode(associatedPersons, forKey: CodingKey.associatedPersons.rawValue)
        aCoder.encode(associatedVehicles, forKey: CodingKey.associatedVehicles.rawValue)
        aCoder.encode(events, forKey: CodingKey.events.rawValue)
        aCoder.encode(addresses, forKey: CodingKey.addresses.rawValue)
        aCoder.encode(media, forKey: CodingKey.media.rawValue)

        aCoder.encode(eventType, forKey: CodingKey.eventType.rawValue)
        aCoder.encode(name, forKey: CodingKey.name.rawValue)
        aCoder.encode(title, forKey: CodingKey.title.rawValue)
        aCoder.encode(eventDescription, forKey: CodingKey.eventDescription.rawValue)
        aCoder.encode(occurredDate, forKey: CodingKey.occurredDate.rawValue)
    }

}

private enum CodingKey: String {
    case id
    case details
    case effectiveDate
    case dateCreated
    case dateUpdated
    case createdBy
    case updatedBy
    case expiryDate
    case entityType
    case isSummary
    case arn
    case jurisdiction
    case source
    case alertLevel
    case associatedAlertLevel

    case alerts
    case associatedPersons
    case associatedVehicles
    case events
    case addresses
    case media

    case eventType
    case name
    case title
    case eventDescription
    case status
    case occurredDate

}
