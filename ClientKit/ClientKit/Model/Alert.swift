//
//  Alert.swift
//  
//
//  Created by Herli Halim on 28/3/17.
//
//

import MPOLKit
import Unbox

@objc(MPLAlert)
open class Alert: NSObject, Serialisable {
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public enum Level: Int, UnboxableEnum {
        case low    = 0
        case medium = 1
        case high   = 2
        
        public static let allCases: [Level] = [.low, .medium, .high]
        
        public var color: UIColor? {
            switch self {
            case .high:   return #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            case .medium: return #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
            case .low:    return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }
        
        public func localizedDescription() -> String? {
            switch self {
            case .high:   return NSLocalizedString("High",     bundle: .mpolKit, comment: "Alert Level Title")
            case .medium: return NSLocalizedString("Medium", bundle: .mpolKit, comment: "Alert Level Title")
            case .low:    return NSLocalizedString("Low",      bundle: .mpolKit, comment: "Alert Level Title")
            }
        }
    }
    
    open var id: String
    open var level: Alert.Level?
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    
    open var source: MPOLSource?
    open var title: String?
    open var details: String?
    
    
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
        
        self.id       = id
        self.level    = unboxer.unbox(key: "alertLevel")
        
        dateCreated   = unboxer.unbox(key: "dateCreated", formatter: Alert.dateTransformer)
        dateUpdated   = unboxer.unbox(key: "dateLastUpdated", formatter: Alert.dateTransformer)
        createdBy     = unboxer.unbox(key: "createdBy")
        updatedBy     = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alert.dateTransformer)
        expiryDate    = unboxer.unbox(key: "expiryDate", formatter: Alert.dateTransformer)
        entityType    = unboxer.unbox(key: "entityType")
        isSummary     = unboxer.unbox(key: "isSummary")

        source        = unboxer.unbox(key: "source")
        title         = unboxer.unbox(key: "title")
        details       = unboxer.unbox(key: "remarks")
        
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
        
        if aDecoder.containsValue(forKey: CodingKey.level.rawValue),
            let level = Level(rawValue: aDecoder.decodeInteger(forKey: CodingKey.level.rawValue)) {
            self.level = level
        } else {
            level = nil
        }
        
        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.level.rawValue)
        if let level = self.level?.rawValue {
            aCoder.encode(level, forKey: CodingKey.level.rawValue)
        }
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // MARK: - Model Versionable
    open static var modelVersion: Int {
        return 0
    }
}

extension Alert.Level: Pickable {
    
    public var title: String? {
        return self.localizedDescription()
    }
    
    public var subtitle: String? {
        return nil
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

