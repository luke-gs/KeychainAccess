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

open class Event: NSObject, Serialisable {

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    open class var serverTypeRepresentation: String {
        return "event"
    }
    
    public class var supportsSecureCoding: Bool {
        return true
    }
        
    open let id: String
    
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
    
    public required init(id: String) {
        self.id = id
        
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Event.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Event.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Event.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Event.dateTransformer)
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
        
        eventType = unboxer.unbox(key: "eventType")
        name = unboxer.unbox(key: "name")
        title = unboxer.unbox(key: "title")
        eventDescription = unboxer.unbox(key: "description")
        status = unboxer.unbox(key: "status")
        occurredDate = unboxer.unbox(key: "occurred", formatter: Event.dateTransformer)
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? else {
            return nil
        }
        
        self.id = id
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    
}
