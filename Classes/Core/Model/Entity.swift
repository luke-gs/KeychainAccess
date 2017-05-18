//
//  Entity.swift
//  MPOL
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

open class Entity: NSObject, Serialisable {
    
    open let id: String
    open var alertLevel: AlertLevel?
    open var associatedAlertLevel: AlertLevel?
    
    open var alerts: [AlertLevel]?
    
    public required init(id: String = NSUUID().uuidString) {
        self.id = id
        super.init()
    }
    
    // MARK: - Unboxable
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id

        self.alertLevel = unboxer.unbox(key: "alertLevel")
        self.associatedAlertLevel = unboxer.unbox(key: "associatedAlertLevel")
        
        self.alerts = unboxer.unbox(key: "alerts")

    }
    
    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String? else {
            return nil
        }
        
        self.id = id
        
        alertLevel = AlertLevel(rawValue: aDecoder.decodeInteger(forKey: CodingKey.alertLevel.rawValue))
        associatedAlertLevel = AlertLevel(rawValue: aDecoder.decodeInteger(forKey: CodingKey.alertLevel.rawValue))

        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)
        
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        
        if let alertLevel = alertLevel {
            aCoder.encode(alertLevel.rawValue, forKey: CodingKey.alertLevel.rawValue)
        }
        
        if let associatedAlertLevel = associatedAlertLevel {
            aCoder.encode(associatedAlertLevel.rawValue, forKey: CodingKey.associatedAlertLevel.rawValue)
        }
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Model Versionable
    
    open class var modelVersion: Int {
        return 0
    }
}

private enum CodingKey: String {
    case version
    case id
    case alertLevel
    case associatedAlertLevel
}
