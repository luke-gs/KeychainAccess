//
//    CADIncident.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class CADIncident : NSObject, NSCoding {

    var actions : [AnyObject]!
    var activityCode : AnyObject!
    var alertLevel : Int!
    var alerts : [AnyObject]!
    var arn : String!
    var associatedAlertLevel : Int!
    var auditName : String!
    var cases : [AnyObject]!
    var createdBy : String!
    var dateCreated : String!
    var dateLastUpdated : String!
    var details : String!
    var effectiveDate : String!
    var entityType : String!
    var events : [AnyObject]!
    var expiryDate : AnyObject!
    var grade : String!
    var id : String!
    var incidentResources : [AnyObject]!
    var jurisdiction : AnyObject!
    var locations : [AnyObject]!
    var mediaItems : [AnyObject]!
    var organisations : [AnyObject]!
    var persons : [AnyObject]!
    var scheduledTimestamp : AnyObject!
    var severity : Int!
    var source : String!
    var status : String!
    var updatedBy : String!
    var vehicles : [AnyObject]!
    var visible : Bool!
    var warningFlag : Bool!
    var zone : String!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]) {
        actions = dictionary["actions"] as? [AnyObject]
        activityCode = dictionary["activityCode"] as AnyObject
        alertLevel = dictionary["alertLevel"] as? Int
        alerts = dictionary["alerts"] as? [AnyObject]
        arn = dictionary["arn"] as? String
        associatedAlertLevel = dictionary["associatedAlertLevel"] as? Int
        auditName = dictionary["auditName"] as? String
        cases = dictionary["cases"] as? [AnyObject]
        createdBy = dictionary["createdBy"] as? String
        dateCreated = dictionary["dateCreated"] as? String
        dateLastUpdated = dictionary["dateLastUpdated"] as? String
        details = dictionary["details"] as? String
        effectiveDate = dictionary["effectiveDate"] as? String
        entityType = dictionary["entityType"] as? String
        events = dictionary["events"] as? [AnyObject]
        expiryDate = dictionary["expiryDate"] as AnyObject
        grade = dictionary["grade"] as? String
        id = dictionary["id"] as? String
        incidentResources = dictionary["incidentResources"] as? [AnyObject]
        jurisdiction = dictionary["jurisdiction"] as AnyObject
        locations = dictionary["locations"] as? [AnyObject]
        mediaItems = dictionary["mediaItems"] as? [AnyObject]
        organisations = dictionary["organisations"] as? [AnyObject]
        persons = dictionary["persons"] as? [AnyObject]
        scheduledTimestamp = dictionary["scheduledTimestamp"] as AnyObject
        severity = dictionary["severity"] as? Int
        source = dictionary["source"] as? String
        status = dictionary["status"] as? String
        updatedBy = dictionary["updatedBy"] as? String
        vehicles = dictionary["vehicles"] as? [AnyObject]
        visible = dictionary["visible"] as? Bool
        warningFlag = dictionary["warningFlag"] as? Bool
        zone = dictionary["zone"] as? String
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if actions != nil{
            dictionary["actions"] = actions
        }
        if activityCode != nil{
            dictionary["activityCode"] = activityCode
        }
        if alertLevel != nil{
            dictionary["alertLevel"] = alertLevel
        }
        if alerts != nil{
            dictionary["alerts"] = alerts
        }
        if arn != nil{
            dictionary["arn"] = arn
        }
        if associatedAlertLevel != nil{
            dictionary["associatedAlertLevel"] = associatedAlertLevel
        }
        if auditName != nil{
            dictionary["auditName"] = auditName
        }
        if cases != nil{
            dictionary["cases"] = cases
        }
        if createdBy != nil{
            dictionary["createdBy"] = createdBy
        }
        if dateCreated != nil{
            dictionary["dateCreated"] = dateCreated
        }
        if dateLastUpdated != nil{
            dictionary["dateLastUpdated"] = dateLastUpdated
        }
        if details != nil{
            dictionary["details"] = details
        }
        if effectiveDate != nil{
            dictionary["effectiveDate"] = effectiveDate
        }
        if entityType != nil{
            dictionary["entityType"] = entityType
        }
        if events != nil{
            dictionary["events"] = events
        }
        if expiryDate != nil{
            dictionary["expiryDate"] = expiryDate
        }
        if grade != nil{
            dictionary["grade"] = grade
        }
        if id != nil{
            dictionary["id"] = id
        }
        if incidentResources != nil{
            dictionary["incidentResources"] = incidentResources
        }
        if jurisdiction != nil{
            dictionary["jurisdiction"] = jurisdiction
        }
        if locations != nil{
            dictionary["locations"] = locations
        }
        if mediaItems != nil{
            dictionary["mediaItems"] = mediaItems
        }
        if organisations != nil{
            dictionary["organisations"] = organisations
        }
        if persons != nil{
            dictionary["persons"] = persons
        }
        if scheduledTimestamp != nil{
            dictionary["scheduledTimestamp"] = scheduledTimestamp
        }
        if severity != nil{
            dictionary["severity"] = severity
        }
        if source != nil{
            dictionary["source"] = source
        }
        if status != nil{
            dictionary["status"] = status
        }
        if updatedBy != nil{
            dictionary["updatedBy"] = updatedBy
        }
        if vehicles != nil{
            dictionary["vehicles"] = vehicles
        }
        if visible != nil{
            dictionary["visible"] = visible
        }
        if warningFlag != nil{
            dictionary["warningFlag"] = warningFlag
        }
        if zone != nil{
            dictionary["zone"] = zone
        }
        return dictionary
    }

    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        actions = aDecoder.decodeObject(forKey: "actions") as? [AnyObject]
        activityCode = aDecoder.decodeObject(forKey: "activityCode") as AnyObject
        alertLevel = aDecoder.decodeObject(forKey: "alertLevel") as? Int
        alerts = aDecoder.decodeObject(forKey: "alerts") as? [AnyObject]
        arn = aDecoder.decodeObject(forKey: "arn") as? String
        associatedAlertLevel = aDecoder.decodeObject(forKey: "associatedAlertLevel") as? Int
        auditName = aDecoder.decodeObject(forKey: "auditName") as? String
        cases = aDecoder.decodeObject(forKey: "cases") as? [AnyObject]
        createdBy = aDecoder.decodeObject(forKey: "createdBy") as? String
        dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as? String
        dateLastUpdated = aDecoder.decodeObject(forKey: "dateLastUpdated") as? String
        details = aDecoder.decodeObject(forKey: "details") as? String
        effectiveDate = aDecoder.decodeObject(forKey: "effectiveDate") as? String
        entityType = aDecoder.decodeObject(forKey: "entityType") as? String
        events = aDecoder.decodeObject(forKey: "events") as? [AnyObject]
        expiryDate = aDecoder.decodeObject(forKey: "expiryDate") as AnyObject
        grade = aDecoder.decodeObject(forKey: "grade") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        incidentResources = aDecoder.decodeObject(forKey: "incidentResources") as? [AnyObject]
        jurisdiction = aDecoder.decodeObject(forKey: "jurisdiction") as AnyObject
        locations = aDecoder.decodeObject(forKey: "locations") as? [AnyObject]
        mediaItems = aDecoder.decodeObject(forKey: "mediaItems") as? [AnyObject]
        organisations = aDecoder.decodeObject(forKey: "organisations") as? [AnyObject]
        persons = aDecoder.decodeObject(forKey: "persons") as? [AnyObject]
        scheduledTimestamp = aDecoder.decodeObject(forKey: "scheduledTimestamp") as AnyObject
        severity = aDecoder.decodeObject(forKey: "severity") as? Int
        source = aDecoder.decodeObject(forKey: "source") as? String
        status = aDecoder.decodeObject(forKey: "status") as? String
        updatedBy = aDecoder.decodeObject(forKey: "updatedBy") as? String
        vehicles = aDecoder.decodeObject(forKey: "vehicles") as? [AnyObject]
        visible = aDecoder.decodeObject(forKey: "visible") as? Bool
        warningFlag = aDecoder.decodeObject(forKey: "warningFlag") as? Bool
        zone = aDecoder.decodeObject(forKey: "zone") as? String

    }

    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc func encode(with aCoder: NSCoder)
    {
        if actions != nil{
            aCoder.encode(actions, forKey: "actions")
        }
        if activityCode != nil{
            aCoder.encode(activityCode, forKey: "activityCode")
        }
        if alertLevel != nil{
            aCoder.encode(alertLevel, forKey: "alertLevel")
        }
        if alerts != nil{
            aCoder.encode(alerts, forKey: "alerts")
        }
        if arn != nil{
            aCoder.encode(arn, forKey: "arn")
        }
        if associatedAlertLevel != nil{
            aCoder.encode(associatedAlertLevel, forKey: "associatedAlertLevel")
        }
        if auditName != nil{
            aCoder.encode(auditName, forKey: "auditName")
        }
        if cases != nil{
            aCoder.encode(cases, forKey: "cases")
        }
        if createdBy != nil{
            aCoder.encode(createdBy, forKey: "createdBy")
        }
        if dateCreated != nil{
            aCoder.encode(dateCreated, forKey: "dateCreated")
        }
        if dateLastUpdated != nil{
            aCoder.encode(dateLastUpdated, forKey: "dateLastUpdated")
        }
        if details != nil{
            aCoder.encode(details, forKey: "details")
        }
        if effectiveDate != nil{
            aCoder.encode(effectiveDate, forKey: "effectiveDate")
        }
        if entityType != nil{
            aCoder.encode(entityType, forKey: "entityType")
        }
        if events != nil{
            aCoder.encode(events, forKey: "events")
        }
        if expiryDate != nil{
            aCoder.encode(expiryDate, forKey: "expiryDate")
        }
        if grade != nil{
            aCoder.encode(grade, forKey: "grade")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if incidentResources != nil{
            aCoder.encode(incidentResources, forKey: "incidentResources")
        }
        if jurisdiction != nil{
            aCoder.encode(jurisdiction, forKey: "jurisdiction")
        }
        if locations != nil{
            aCoder.encode(locations, forKey: "locations")
        }
        if mediaItems != nil{
            aCoder.encode(mediaItems, forKey: "mediaItems")
        }
        if organisations != nil{
            aCoder.encode(organisations, forKey: "organisations")
        }
        if persons != nil{
            aCoder.encode(persons, forKey: "persons")
        }
        if scheduledTimestamp != nil{
            aCoder.encode(scheduledTimestamp, forKey: "scheduledTimestamp")
        }
        if severity != nil{
            aCoder.encode(severity, forKey: "severity")
        }
        if source != nil{
            aCoder.encode(source, forKey: "source")
        }
        if status != nil{
            aCoder.encode(status, forKey: "status")
        }
        if updatedBy != nil{
            aCoder.encode(updatedBy, forKey: "updatedBy")
        }
        if vehicles != nil{
            aCoder.encode(vehicles, forKey: "vehicles")
        }
        if visible != nil{
            aCoder.encode(visible, forKey: "visible")
        }
        if warningFlag != nil{
            aCoder.encode(warningFlag, forKey: "warningFlag")
        }
        if zone != nil{
            aCoder.encode(zone, forKey: "zone")
        }

    }

}

