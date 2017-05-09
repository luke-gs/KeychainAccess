//
//  EntityAlert.swift
//  
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

open class EntityAlert: NSObject, Serialisable {
    
    open var id: String
    open var level: AlertLevel
    
    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? EntityAlert {
            return object.id == self.id
        }
        return super.isEqual(object)
    }
    
    // MARK: - Unboxable
    
    required public init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id"),
              let level: AlertLevel = unboxer.unbox(key: "alertLevel") else {
                throw ParsingError.missingRequiredField
        }
        
        self.id = id
        self.level = level

    }
    
    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?,
            let level = AlertLevel(rawValue: aDecoder.decodeInteger(forKey: CodingKey.level.rawValue)) else {
            return nil
        }
        
        self.id = id
        self.level = level
        
        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.level.rawValue)
        aCoder.encode(level.rawValue, forKey: CodingKey.level.rawValue)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Model Versionable
    open static var modelVersion: Int {
        return 0
    }
}

private enum CodingKey: String {
    case version
    case id
    case level
}
