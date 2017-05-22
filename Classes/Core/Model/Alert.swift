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
    
    public enum Level: Int, UnboxableEnum {
        case none   = 0
        case low    = 1
        case medium = 2
        case high   = 3
        
        public var color: UIColor {
            switch self {
            case .high:   return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            case .medium: return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
            case .low:    return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
            case .none:   return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }
        
        public func localizedDescription(plural: Bool) -> String {
            if plural {
                switch self {
                case .high:   return NSLocalizedString("Safety Warnings",     bundle: .mpolKit, comment: "Alert Level Title")
                case .medium: return NSLocalizedString("Actions",             bundle: .mpolKit, comment: "Alert Level Title")
                case .low:    return NSLocalizedString("Persons Of Interest", bundle: .mpolKit, comment: "Alert Level Title")
                case .none:   return NSLocalizedString("Interest Flags",      bundle: .mpolKit, comment: "Alert Level Title")
                }
            } else {
                switch self {
                case .high:   return NSLocalizedString("Safety Warning",     bundle: .mpolKit, comment: "Alert Level Title")
                case .medium: return NSLocalizedString("Action",             bundle: .mpolKit, comment: "Alert Level Title")
                case .low:    return NSLocalizedString("Person Of Interest", bundle: .mpolKit, comment: "Alert Level Title")
                case .none:   return NSLocalizedString("Interest Flag",      bundle: .mpolKit, comment: "Alert Level Title")
                }
            }
        }
        
    }
    
    open var id: String
    open var level: Alert.Level
    
    
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
        
        guard let id: String = unboxer.unbox(key: "id"),
              let level: Alert.Level = unboxer.unbox(key: "alertLevel") else {
                throw ParsingError.missingRequiredField
        }
        
        self.id = id
        self.level = level
        
        // temp properties
        title   = unboxer.unbox(key: "title")
        details = unboxer.unbox(key: "details")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alert.dateTransformer)
        
        super.init()
    }
    
    // MARK: - NSSecureCoding
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String?,
            let level = Alert.Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.level.rawValue)) else {
            return nil
        }
        
        self.id = id
        self.level = level
        
        title = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.title.rawValue) as String?
        details = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.details.rawValue) as String?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        
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
    case title
    case details
    case effectiveDate
}
