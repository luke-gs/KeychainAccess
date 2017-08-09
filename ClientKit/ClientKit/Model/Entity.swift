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

    open var source: Source?
    open var alertLevel: Alert.Level?
    open var associatedAlertLevel: Alert.Level?
    
    open var actionCount: UInt = 0
    
    open var alerts: [Alert]?
    
    open var associatedPersons: [Person]?
    open var associatedVehicles: [Vehicle]?
    
    // MARK: - Temp properties
    open var lastUpdated: Date?

    override public init(id: String) {
        super.init(id: id)
    }

    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {
        self.source = unboxer.unbox(key: "source")

        self.alertLevel = unboxer.unbox(key: "alertLevel")
        self.associatedAlertLevel = unboxer.unbox(key: "associatedAlertLevel")
        self.alerts = unboxer.unbox(key: "alerts")
        
        if let actionCount: UInt = unboxer.unbox(key: "actionCount") {
            self.actionCount = actionCount
        }
        
        associatedPersons = unboxer.unbox(key: "persons")
        associatedVehicles = unboxer.unbox(key: "vehicles")
        
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
    case alertLevel
    case associatedAlertLevel
}
