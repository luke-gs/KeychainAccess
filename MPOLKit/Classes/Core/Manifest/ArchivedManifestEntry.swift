//
//  ArchivedManifestEntry.swift
//  Pods
//
//  Created by Rod Brown on 19/4/17.
//
//

import Foundation
import CoreLocation

open class ArchivedManifestEntry: NSObject, NSCoding {
    
    // MARK: - Public properties
    
    public let isActive: Bool
    public let additionalDetails: [String: Any]?
    public let code: String?
    public let collection: String?
    public let effectiveDate: Date?
    public let expiryDate: Date?
    public let id: String?
    public let lastUpdated: Date?
    public let location: CLLocationCoordinate2D
    public let rawValue: String?
    public let shortTitle: String?
    public let sortOrder: Double
    public let subtitle: String?
    public let title: String?
    
    
    // MARK: - Initializers
    
    public init(entry: ManifestEntry) {
        isActive      = entry.active
        additionalDetails = entry.additionalDetails
        code          = entry.code
        collection    = entry.collection
        effectiveDate = entry.effectiveDate as Date?
        expiryDate    = entry.expiryDate  as Date?
        id            = entry.id
        lastUpdated   = entry.lastUpdated as Date?
        if let latitude = entry.latitude?.doubleValue, let longitude = entry.longitude?.doubleValue {
            self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.location = kCLLocationCoordinate2DInvalid
        }
        rawValue      = entry.rawValue
        shortTitle    = entry.shortTitle
        sortOrder     = entry.sortOrder
        subtitle      = entry.subtitle
        title         = entry.title
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        isActive        = aDecoder.decodeBool(forKey: #keyPath(isActive))
        additionalDetails = aDecoder.decodeObject(of: NSDictionary.self, forKey: #keyPath(additionalDetails)) as? [String: Any]
        code            = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(code))        as String?
        collection      = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(collection))  as String?
        effectiveDate   = aDecoder.decodeObject(of: NSDate.self,   forKey: #keyPath(effectiveDate)) as Date?
        expiryDate      = aDecoder.decodeObject(of: NSDate.self,   forKey: #keyPath(expiryDate))  as Date?
        id              = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(id))          as String?
        lastUpdated     = aDecoder.decodeObject(of: NSDate.self,   forKey: #keyPath(lastUpdated)) as Date?
        location        = aDecoder.decodeObject(of: NSValue.self,  forKey: #keyPath(location))?.mkCoordinateValue ?? kCLLocationCoordinate2DInvalid
        rawValue        = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(rawValue))    as String?
        shortTitle      = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(shortTitle))  as String?
        sortOrder       = aDecoder.decodeDouble(forKey: #keyPath(sortOrder))
        subtitle        = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(subtitle))    as String?
        title           = aDecoder.decodeObject(of: NSString.self, forKey: #keyPath(title))       as String?
        
        super.init()
    }
    
    
    // MARK: - Encoding
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(isActive,    forKey: #keyPath(isActive))
        aCoder.encode(additionalDetails, forKey: #keyPath(additionalDetails))
        aCoder.encode(code,        forKey: #keyPath(code))
        aCoder.encode(collection,  forKey: #keyPath(collection))
        aCoder.encode(effectiveDate, forKey: #keyPath(effectiveDate))
        aCoder.encode(expiryDate,  forKey: #keyPath(expiryDate))
        aCoder.encode(id,          forKey: #keyPath(id))
        aCoder.encode(lastUpdated, forKey: #keyPath(lastUpdated))
        aCoder.encode(NSValue(mkCoordinate: location), forKey: #keyPath(location))
        aCoder.encode(rawValue,    forKey: #keyPath(rawValue))
        aCoder.encode(shortTitle,  forKey: #keyPath(shortTitle))
        aCoder.encode(sortOrder,   forKey: #keyPath(sortOrder))
        aCoder.encode(subtitle,    forKey: #keyPath(subtitle))
        aCoder.encode(title,       forKey: #keyPath(title))
    }
    
    
    
}
