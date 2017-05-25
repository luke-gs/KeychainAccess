//
//  Entity.swift
//  MPOL
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

@objc(MPLEntity)
open class Entity: NSObject, Serialisable {
    
    
    open class var localizedDisplayName: String {
        return NSLocalizedString("Entity", comment: "")
    }
    
    
    open let id: String
    open var source: Source?
    open var alertLevel: Alert.Level?
    open var associatedAlertLevel: Alert.Level?
    
    open var actionCount: UInt = 0
    
    open var alerts: [Alert]?
    
    
    // MARK: - Temp properties
    open var lastUpdated: Date?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        self.source = unboxer.unbox(key: "source")

        self.alertLevel = unboxer.unbox(key: "alertLevel")
        self.associatedAlertLevel = unboxer.unbox(key: "associatedAlertLevel")
        self.alerts = unboxer.unbox(key: "alerts")
        
        if let actionCount: UInt = unboxer.unbox(key: "actionCount") {
            self.actionCount = actionCount
        }

        super.init()
    }
    
    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String? else {
            return nil
        }
        
        self.id = id
        
        if aDecoder.containsValue(forKey: CodingKey.alertLevel.rawValue) {
            alertLevel = aDecoder.decodeInteger(forKey: CodingKey.alertLevel.rawValue)
        }
        if aDecoder.containsValue(forKey: CodingKey.associatedAlertLevel.rawValue) {
            associatedAlertLevel = aDecoder.decodeInteger(forKey: CodingKey.associatedAlertLevel.rawValue)
        }
        
        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)
        
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        
        if let alertLevel = alertLevel {
            aCoder.encode(alertLevel, forKey: CodingKey.alertLevel.rawValue)
        }
        
        if let associatedAlertLevel = associatedAlertLevel {
            aCoder.encode(associatedAlertLevel, forKey: CodingKey.associatedAlertLevel.rawValue)
        }
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    
    // MARK: - Model Versionable
    
    open class var modelVersion: Int {
        return 0
    }
    
    
    // MARK: - Display
    
    // TEMPORARY
    open func thumbnailImage(ofSize size: EntityThumbnailView.ThumbnailSize) -> (image: UIImage, mode: UIViewContentMode)? {
        return nil
    }
    
    open var summary: String {
        return "-"
    }
    
    open var summaryDetail1: String? {
        return nil
    }
    
    open var summaryDetail2: String? {
        return nil
    }
    
}

private enum CodingKey: String {
    case version
    case id
    case alertLevel
    case associatedAlertLevel
}
