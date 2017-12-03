//
//  PhoneNumber.swift
//  Pods
//
//  Created by Gridstone on 7/6/17.
//
//

import Unbox
import MPOLKit

@objc(MPLPhoneNumber)
open class PhoneNumber: NSObject, Serialisable {
    
    open let id : String
    
    open var type: String?
    open var areaCode: String?
    open var phoneNumber: String?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        // Test data doesn't have id, temporarily removed this
//        guard let id: String = unboxer.unbox(key: "id") else {
//            throw ParsingError.missingRequiredField
//        }

        if let id: String = unboxer.unbox(key: "id") {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        
        type = unboxer.unbox(key: "type")
        areaCode = unboxer.unbox(key: "areaCode")
        phoneNumber = unboxer.unbox(key: "phoneNumber")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!

        super.init()

        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.type.rawValue) as String?
        areaCode = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.areaCode.rawValue) as String?
        phoneNumber = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.phoneNumber.rawValue) as String?
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(PhoneNumber.modelVersion, forKey: CodingKey.version.rawValue)
        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(type, forKey: CodingKey.type.rawValue)
        aCoder.encode(areaCode, forKey: CodingKey.areaCode.rawValue)
        aCoder.encode(phoneNumber, forKey: CodingKey.phoneNumber.rawValue)
    }
    
    open static var supportsSecureCoding: Bool { return true }

    open static var modelVersion: Int { return 0 }
    
    
    // MARK: - Temp Formatters
    
    func formattedNumber() -> String? {
        if let number = phoneNumber {
            if let areaCode = areaCode {
                return "\(areaCode) \(number)"
            } else {
                return number
            }
        }
        return nil
    }
    
    func formattedType() -> String {
        guard let type = type else { return "Unknown" }
        switch type {
        case "MOBL":    return "Mobile"
        case "HOME":    return "Home"
        case "BUS":     return "Business"
        case "OTHR":    return "Other"
        default:        return "Unknown"      // Should default types be "Unknown" or "Other"
        }
    }

    private enum CodingKey: String {
        case version
        case id
        case type
        case areaCode
        case phoneNumber
    }
}
