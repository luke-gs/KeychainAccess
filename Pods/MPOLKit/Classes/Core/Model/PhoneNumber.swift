//
//  PhoneNumber.swift
//  Pods
//
//  Created by Gridstone on 7/6/17.
//
//

import Unbox

@objc(MPLPhoneNumber)
open class PhoneNumber: NSObject, Serialisable {
    
    open let id : String
    
    open var type : String?
    open var areaCode : String?
    open var phoneNumber : String?
    
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
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
    
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
}
