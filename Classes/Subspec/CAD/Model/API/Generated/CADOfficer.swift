//
//	CADOfficer.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class CADOfficer : NSObject, NSCoding{

	var actions : [AnyObject]!
	var alertLevel : Int!
	var alerts : [AnyObject]!
	var alias : String!
	var arn : String!
	var associatedAlertLevel : Int!
	var auditName : String!
	var callsign : AnyObject!
	var callsignAlias : AnyObject!
	var cases : [AnyObject]!
	var createdBy : String!
	var currentLocation : AnyObject!
	var dateCreated : String!
	var dateLastUpdated : String!
	var effectiveDate : String!
	var employeeNumber : String!
	var entityType : String!
	var events : [AnyObject]!
	var expiryDate : AnyObject!
	var externalIdentifiers : CADExternalIdentifier!
	var firstName : String!
	var fullName : AnyObject!
	var id : String!
	var issi : AnyObject!
	var jurisdiction : AnyObject!
	var lastKnownLocation : AnyObject!
	var lastUpdated : AnyObject!
	var locations : [AnyObject]!
	var mediaItems : [AnyObject]!
	var middleName : AnyObject!
	var organisations : [AnyObject]!
	var payrollId : String!
	var persons : [AnyObject]!
	var phoneNumber : AnyObject!
	var primaryUnitId : Int!
	var primaryUnitName : AnyObject!
	var rank : AnyObject!
	var region : String!
	var role : AnyObject!
	var signatureAlias : AnyObject!
	var source : String!
	var station : String!
	var status : String!
	var surname : AnyObject!
	var updatedBy : String!
	var vehicles : [AnyObject]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		actions = dictionary["actions"] as? [AnyObject]
		alertLevel = dictionary["alertLevel"] as? Int
		alerts = dictionary["alerts"] as? [AnyObject]
		alias = dictionary["alias"] as? String
		arn = dictionary["arn"] as? String
		associatedAlertLevel = dictionary["associatedAlertLevel"] as? Int
		auditName = dictionary["auditName"] as? String
		callsign = dictionary["callsign"] as AnyObject
		callsignAlias = dictionary["callsignAlias"] as AnyObject
		cases = dictionary["cases"] as? [AnyObject]
		createdBy = dictionary["createdBy"] as? String
		currentLocation = dictionary["currentLocation"] as AnyObject
		dateCreated = dictionary["dateCreated"] as? String
		dateLastUpdated = dictionary["dateLastUpdated"] as? String
		effectiveDate = dictionary["effectiveDate"] as? String
		employeeNumber = dictionary["employeeNumber"] as? String
		entityType = dictionary["entityType"] as? String
		events = dictionary["events"] as? [AnyObject]
		expiryDate = dictionary["expiryDate"] as AnyObject
		if let externalIdentifiersData = dictionary["externalIdentifiers"] as? [String:Any]{
			externalIdentifiers = CADExternalIdentifier(fromDictionary: externalIdentifiersData)
		}
		firstName = dictionary["firstName"] as? String
		fullName = dictionary["fullName"] as AnyObject
		id = dictionary["id"] as? String
		issi = dictionary["issi"] as AnyObject
		jurisdiction = dictionary["jurisdiction"] as AnyObject
		lastKnownLocation = dictionary["lastKnownLocation"] as AnyObject
		lastUpdated = dictionary["lastUpdated"] as AnyObject
		locations = dictionary["locations"] as? [AnyObject]
		mediaItems = dictionary["mediaItems"] as? [AnyObject]
		middleName = dictionary["middleName"] as AnyObject
		organisations = dictionary["organisations"] as? [AnyObject]
		payrollId = dictionary["payrollId"] as? String
		persons = dictionary["persons"] as? [AnyObject]
		phoneNumber = dictionary["phoneNumber"] as AnyObject
		primaryUnitId = dictionary["primaryUnitId"] as? Int
		primaryUnitName = dictionary["primaryUnitName"] as AnyObject
		rank = dictionary["rank"] as AnyObject
		region = dictionary["region"] as? String
		role = dictionary["role"] as AnyObject
		signatureAlias = dictionary["signatureAlias"] as AnyObject
		source = dictionary["source"] as? String
		station = dictionary["station"] as? String
		status = dictionary["status"] as? String
		surname = dictionary["surname"] as AnyObject
		updatedBy = dictionary["updatedBy"] as? String
		vehicles = dictionary["vehicles"] as? [AnyObject]
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
		if alertLevel != nil{
			dictionary["alertLevel"] = alertLevel
		}
		if alerts != nil{
			dictionary["alerts"] = alerts
		}
		if alias != nil{
			dictionary["alias"] = alias
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
		if callsign != nil{
			dictionary["callsign"] = callsign
		}
		if callsignAlias != nil{
			dictionary["callsignAlias"] = callsignAlias
		}
		if cases != nil{
			dictionary["cases"] = cases
		}
		if createdBy != nil{
			dictionary["createdBy"] = createdBy
		}
		if currentLocation != nil{
			dictionary["currentLocation"] = currentLocation
		}
		if dateCreated != nil{
			dictionary["dateCreated"] = dateCreated
		}
		if dateLastUpdated != nil{
			dictionary["dateLastUpdated"] = dateLastUpdated
		}
		if effectiveDate != nil{
			dictionary["effectiveDate"] = effectiveDate
		}
		if employeeNumber != nil{
			dictionary["employeeNumber"] = employeeNumber
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
		if externalIdentifiers != nil{
			dictionary["externalIdentifiers"] = externalIdentifiers.toDictionary()
		}
		if firstName != nil{
			dictionary["firstName"] = firstName
		}
		if fullName != nil{
			dictionary["fullName"] = fullName
		}
		if id != nil{
			dictionary["id"] = id
		}
		if issi != nil{
			dictionary["issi"] = issi
		}
		if jurisdiction != nil{
			dictionary["jurisdiction"] = jurisdiction
		}
		if lastKnownLocation != nil{
			dictionary["lastKnownLocation"] = lastKnownLocation
		}
		if lastUpdated != nil{
			dictionary["lastUpdated"] = lastUpdated
		}
		if locations != nil{
			dictionary["locations"] = locations
		}
		if mediaItems != nil{
			dictionary["mediaItems"] = mediaItems
		}
		if middleName != nil{
			dictionary["middleName"] = middleName
		}
		if organisations != nil{
			dictionary["organisations"] = organisations
		}
		if payrollId != nil{
			dictionary["payrollId"] = payrollId
		}
		if persons != nil{
			dictionary["persons"] = persons
		}
		if phoneNumber != nil{
			dictionary["phoneNumber"] = phoneNumber
		}
		if primaryUnitId != nil{
			dictionary["primaryUnitId"] = primaryUnitId
		}
		if primaryUnitName != nil{
			dictionary["primaryUnitName"] = primaryUnitName
		}
		if rank != nil{
			dictionary["rank"] = rank
		}
		if region != nil{
			dictionary["region"] = region
		}
		if role != nil{
			dictionary["role"] = role
		}
		if signatureAlias != nil{
			dictionary["signatureAlias"] = signatureAlias
		}
		if source != nil{
			dictionary["source"] = source
		}
		if station != nil{
			dictionary["station"] = station
		}
		if status != nil{
			dictionary["status"] = status
		}
		if surname != nil{
			dictionary["surname"] = surname
		}
		if updatedBy != nil{
			dictionary["updatedBy"] = updatedBy
		}
		if vehicles != nil{
			dictionary["vehicles"] = vehicles
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
         alertLevel = aDecoder.decodeObject(forKey: "alertLevel") as? Int
         alerts = aDecoder.decodeObject(forKey: "alerts") as? [AnyObject]
         alias = aDecoder.decodeObject(forKey: "alias") as? String
         arn = aDecoder.decodeObject(forKey: "arn") as? String
         associatedAlertLevel = aDecoder.decodeObject(forKey: "associatedAlertLevel") as? Int
         auditName = aDecoder.decodeObject(forKey: "auditName") as? String
         callsign = aDecoder.decodeObject(forKey: "callsign") as AnyObject
         callsignAlias = aDecoder.decodeObject(forKey: "callsignAlias") as AnyObject
         cases = aDecoder.decodeObject(forKey: "cases") as? [AnyObject]
         createdBy = aDecoder.decodeObject(forKey: "createdBy") as? String
         currentLocation = aDecoder.decodeObject(forKey: "currentLocation") as AnyObject
         dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as? String
         dateLastUpdated = aDecoder.decodeObject(forKey: "dateLastUpdated") as? String
         effectiveDate = aDecoder.decodeObject(forKey: "effectiveDate") as? String
         employeeNumber = aDecoder.decodeObject(forKey: "employeeNumber") as? String
         entityType = aDecoder.decodeObject(forKey: "entityType") as? String
         events = aDecoder.decodeObject(forKey: "events") as? [AnyObject]
         expiryDate = aDecoder.decodeObject(forKey: "expiryDate") as AnyObject
         externalIdentifiers = aDecoder.decodeObject(forKey: "externalIdentifiers") as? CADExternalIdentifier
         firstName = aDecoder.decodeObject(forKey: "firstName") as? String
         fullName = aDecoder.decodeObject(forKey: "fullName") as AnyObject
         id = aDecoder.decodeObject(forKey: "id") as? String
         issi = aDecoder.decodeObject(forKey: "issi") as AnyObject
         jurisdiction = aDecoder.decodeObject(forKey: "jurisdiction") as AnyObject
         lastKnownLocation = aDecoder.decodeObject(forKey: "lastKnownLocation") as AnyObject
         lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as AnyObject
         locations = aDecoder.decodeObject(forKey: "locations") as? [AnyObject]
         mediaItems = aDecoder.decodeObject(forKey: "mediaItems") as? [AnyObject]
         middleName = aDecoder.decodeObject(forKey: "middleName") as AnyObject
         organisations = aDecoder.decodeObject(forKey: "organisations") as? [AnyObject]
         payrollId = aDecoder.decodeObject(forKey: "payrollId") as? String
         persons = aDecoder.decodeObject(forKey: "persons") as? [AnyObject]
         phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as AnyObject
         primaryUnitId = aDecoder.decodeObject(forKey: "primaryUnitId") as? Int
         primaryUnitName = aDecoder.decodeObject(forKey: "primaryUnitName") as AnyObject
         rank = aDecoder.decodeObject(forKey: "rank") as AnyObject
         region = aDecoder.decodeObject(forKey: "region") as? String
         role = aDecoder.decodeObject(forKey: "role") as AnyObject
         signatureAlias = aDecoder.decodeObject(forKey: "signatureAlias") as AnyObject
         source = aDecoder.decodeObject(forKey: "source") as? String
         station = aDecoder.decodeObject(forKey: "station") as? String
         status = aDecoder.decodeObject(forKey: "status") as? String
         surname = aDecoder.decodeObject(forKey: "surname") as AnyObject
         updatedBy = aDecoder.decodeObject(forKey: "updatedBy") as? String
         vehicles = aDecoder.decodeObject(forKey: "vehicles") as? [AnyObject]

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
		if alertLevel != nil{
			aCoder.encode(alertLevel, forKey: "alertLevel")
		}
		if alerts != nil{
			aCoder.encode(alerts, forKey: "alerts")
		}
		if alias != nil{
			aCoder.encode(alias, forKey: "alias")
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
		if callsign != nil{
			aCoder.encode(callsign, forKey: "callsign")
		}
		if callsignAlias != nil{
			aCoder.encode(callsignAlias, forKey: "callsignAlias")
		}
		if cases != nil{
			aCoder.encode(cases, forKey: "cases")
		}
		if createdBy != nil{
			aCoder.encode(createdBy, forKey: "createdBy")
		}
		if currentLocation != nil{
			aCoder.encode(currentLocation, forKey: "currentLocation")
		}
		if dateCreated != nil{
			aCoder.encode(dateCreated, forKey: "dateCreated")
		}
		if dateLastUpdated != nil{
			aCoder.encode(dateLastUpdated, forKey: "dateLastUpdated")
		}
		if effectiveDate != nil{
			aCoder.encode(effectiveDate, forKey: "effectiveDate")
		}
		if employeeNumber != nil{
			aCoder.encode(employeeNumber, forKey: "employeeNumber")
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
		if externalIdentifiers != nil{
			aCoder.encode(externalIdentifiers, forKey: "externalIdentifiers")
		}
		if firstName != nil{
			aCoder.encode(firstName, forKey: "firstName")
		}
		if fullName != nil{
			aCoder.encode(fullName, forKey: "fullName")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if issi != nil{
			aCoder.encode(issi, forKey: "issi")
		}
		if jurisdiction != nil{
			aCoder.encode(jurisdiction, forKey: "jurisdiction")
		}
		if lastKnownLocation != nil{
			aCoder.encode(lastKnownLocation, forKey: "lastKnownLocation")
		}
		if lastUpdated != nil{
			aCoder.encode(lastUpdated, forKey: "lastUpdated")
		}
		if locations != nil{
			aCoder.encode(locations, forKey: "locations")
		}
		if mediaItems != nil{
			aCoder.encode(mediaItems, forKey: "mediaItems")
		}
		if middleName != nil{
			aCoder.encode(middleName, forKey: "middleName")
		}
		if organisations != nil{
			aCoder.encode(organisations, forKey: "organisations")
		}
		if payrollId != nil{
			aCoder.encode(payrollId, forKey: "payrollId")
		}
		if persons != nil{
			aCoder.encode(persons, forKey: "persons")
		}
		if phoneNumber != nil{
			aCoder.encode(phoneNumber, forKey: "phoneNumber")
		}
		if primaryUnitId != nil{
			aCoder.encode(primaryUnitId, forKey: "primaryUnitId")
		}
		if primaryUnitName != nil{
			aCoder.encode(primaryUnitName, forKey: "primaryUnitName")
		}
		if rank != nil{
			aCoder.encode(rank, forKey: "rank")
		}
		if region != nil{
			aCoder.encode(region, forKey: "region")
		}
		if role != nil{
			aCoder.encode(role, forKey: "role")
		}
		if signatureAlias != nil{
			aCoder.encode(signatureAlias, forKey: "signatureAlias")
		}
		if source != nil{
			aCoder.encode(source, forKey: "source")
		}
		if station != nil{
			aCoder.encode(station, forKey: "station")
		}
		if status != nil{
			aCoder.encode(status, forKey: "status")
		}
		if surname != nil{
			aCoder.encode(surname, forKey: "surname")
		}
		if updatedBy != nil{
			aCoder.encode(updatedBy, forKey: "updatedBy")
		}
		if vehicles != nil{
			aCoder.encode(vehicles, forKey: "vehicles")
		}

	}

}
