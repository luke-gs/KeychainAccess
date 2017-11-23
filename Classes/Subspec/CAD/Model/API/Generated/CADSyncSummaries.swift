//
//    CADSyncSummaries.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


public class CADSyncSummaries : NSObject, NSCoding{

    var filteredOrgUnits : AnyObject!
    var incidents : [CADIncident]!
    var officers : [CADOfficer]!
    var selectedOrgUnitStructure : AnyObject!


    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    public init(fromDictionary dictionary: [String:Any]) {
        filteredOrgUnits = dictionary["filteredOrgUnits"] as AnyObject
        incidents = [CADIncident]()
        if let incidentsArray = dictionary["incidents"] as? [[String:Any]]{
            for dic in incidentsArray{
                let value = CADIncident(fromDictionary: dic)
                incidents.append(value)
            }
        }
        officers = [CADOfficer]()
        if let officersArray = dictionary["officers"] as? [[String:Any]]{
            for dic in officersArray{
                let value = CADOfficer(fromDictionary: dic)
                officers.append(value)
            }
        }
        selectedOrgUnitStructure = dictionary["selectedOrgUnitStructure"] as AnyObject
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if filteredOrgUnits != nil{
            dictionary["filteredOrgUnits"] = filteredOrgUnits
        }
        if incidents != nil{
            var dictionaryElements = [[String:Any]]()
            for incidentsElement in incidents {
                dictionaryElements.append(incidentsElement.toDictionary())
            }
            dictionary["incidents"] = dictionaryElements
        }
        if officers != nil{
            var dictionaryElements = [[String:Any]]()
            for officersElement in officers {
                dictionaryElements.append(officersElement.toDictionary())
            }
            dictionary["officers"] = dictionaryElements
        }
        if selectedOrgUnitStructure != nil{
            dictionary["selectedOrgUnitStructure"] = selectedOrgUnitStructure
        }
        return dictionary
    }

    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc public required init(coder aDecoder: NSCoder)
    {
        filteredOrgUnits = aDecoder.decodeObject(forKey: "filteredOrgUnits") as AnyObject
        incidents = aDecoder.decodeObject(forKey :"incidents") as? [CADIncident]
        officers = aDecoder.decodeObject(forKey :"officers") as? [CADOfficer]
        selectedOrgUnitStructure = aDecoder.decodeObject(forKey: "selectedOrgUnitStructure") as AnyObject

    }

    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc public func encode(with aCoder: NSCoder)
    {
        if filteredOrgUnits != nil{
            aCoder.encode(filteredOrgUnits, forKey: "filteredOrgUnits")
        }
        if incidents != nil{
            aCoder.encode(incidents, forKey: "incidents")
        }
        if officers != nil{
            aCoder.encode(officers, forKey: "officers")
        }
        if selectedOrgUnitStructure != nil{
            aCoder.encode(selectedOrgUnitStructure, forKey: "selectedOrgUnitStructure")
        }

    }

}

