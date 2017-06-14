//
//  Event.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import Foundation
import Unbox

open class Event: NSObject, Serialisable {
    
    public class var supportsSecureCoding: Bool {
        return true
    }
    
    open let id: String
    open var eventType: String?
    open var eventDescription: String?
    
    public required init(id: String) {
        self.id = id
        
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
//        guard let id: String = unboxer.unbox(key: "id") else {
//            throw ParsingError.missingRequiredField
//        }
//        self.id = id
        
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        eventType = unboxer.unbox(key: "eventType")
        eventDescription = unboxer.unbox(key: "description")

        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? else {
            return nil
        }
        
        self.id = id
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    
}
