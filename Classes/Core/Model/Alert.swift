//
//  Alert.swift
//  
//
//  Created by Herli Halim on 28/3/17.
//
//

import Unbox

@objc(MPLAlert)
open class Alert: NSObject, Serialisable {
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public typealias Level = Int
    
    open var id: String
    open var level: Alert.Level?
    
    
    // MARK: - Temp properties
    open var title: String?
    open var details: String?
    open var effectiveDate: Date?
    
    
    // MARK: - Equality
    
    open override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Alert {
            return object.id == self.id
        }
        return super.isEqual(object)
    }
    
    // MARK: - Temp
    
    public init(id: String, level: Alert.Level) {
        self.id = id
        self.level = level
        
        super.init()
    }
    
    
    // MARK: - Unboxable
    
    required public init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
                throw ParsingError.missingRequiredField
        }
        
        self.id = id
        self.level = unboxer.unbox(key: "alertLevel")
        
        // temp properties
        
        title   = unboxer.unbox(key: "title")
        details = unboxer.unbox(key: "details")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alert.dateTransformer)
        
        super.init()
    }
    
    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String? else {
            return nil
        }
        
        self.id = id
        
        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
        details = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.details.rawValue) as String?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        
        if aDecoder.containsValue(forKey: CodingKey.level.rawValue) {
            level = aDecoder.decodeInteger(forKey: CodingKey.level.rawValue)
        } else {
            level = nil
        }
        
        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.level.rawValue)
        aCoder.encode(level, forKey: CodingKey.level.rawValue)
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
    case title
    case details
    case effectiveDate
}

public extension Alert.Level {
    
    public var color: UIColor? {
        if self == 2 {
            return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
        }
        if self > 2 {
            return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        }
        return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
        
    public func localizedDescription(plural: Bool) -> String? {
        if plural {
            switch self {
            case 3:  return NSLocalizedString("Safety Warnings",     bundle: .mpolKit, comment: "Alert Level Title")
            case 2:  return NSLocalizedString("Persons Of Interest", bundle: .mpolKit, comment: "Alert Level Title")
            case 1:  return NSLocalizedString("Interest Flags",      bundle: .mpolKit, comment: "Alert Level Title")
            default: return nil
            }
        } else {
            switch self {
            case 3:  return NSLocalizedString("Safety Warning",     bundle: .mpolKit, comment: "Alert Level Title")
            case 2:  return NSLocalizedString("Person Of Interest", bundle: .mpolKit, comment: "Alert Level Title")
            case 1:  return NSLocalizedString("Interest Flag",      bundle: .mpolKit, comment: "Alert Level Title")
            default: return nil
            }
        }
    }
    
}
