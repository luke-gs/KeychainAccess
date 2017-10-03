//
//  ArchivedManifestEntry.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import CoreLocation

private let latKey  = "location.latitude"
private let longKey = "location.longitude"

open class ArchivedManifestEntry: NSObject, NSSecureCoding {
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    
    // MARK: - Public properties
    
    @objc public let isActive: Bool
    @objc public let additionalDetails: [String: Any]?
    @objc public let code: String?
    @objc public let collection: String?
    @objc public let effectiveDate: Date?
    @objc public let expiryDate: Date?
    @objc public let id: String?
    @objc public let lastUpdated: Date?
    public let location: CLLocationCoordinate2D
    @objc public let rawValue: String?
    @objc public let shortTitle: String?
    @objc public let sortOrder: Double
    @objc public let subtitle: String?
    @objc public let title: String?
    
    
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
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = kCLLocationCoordinate2DInvalid
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
        location        = CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: latKey), longitude: aDecoder.decodeDouble(forKey: longKey))
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
        aCoder.encode(location.latitude, forKey: latKey)
        aCoder.encode(location.longitude, forKey: longKey)
        aCoder.encode(rawValue,    forKey: #keyPath(rawValue))
        aCoder.encode(shortTitle,  forKey: #keyPath(shortTitle))
        aCoder.encode(sortOrder,   forKey: #keyPath(sortOrder))
        aCoder.encode(subtitle,    forKey: #keyPath(subtitle))
        aCoder.encode(title,       forKey: #keyPath(title))
    }
    
    
    // MARK: - Fetch current version
    
    public func current() -> ManifestEntry? {
        guard let id = self.id else { return nil }
        
        return Manifest.shared.entry(withID: id)
    }
    
}
