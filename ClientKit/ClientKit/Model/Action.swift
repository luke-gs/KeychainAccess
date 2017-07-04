//
//  Action.swift
//  Pods
//
//  Created by Herli Halim on 6/6/17.
//
//

import Unbox
import MPOLKit

@objc(MPLAction)
open class Action: NSObject, Serialisable {
    
    open let id : String
    open var type: String?
    
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        // Test data doesn't have id, temporarily removed this
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        type = unboxer.unbox(key: "actionType")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
}
