//
//  Contact.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class Contact: NSObject, Serialisable {

    open let id : String
    open var type: String?
    open var value: String?
    
    public required init(id: String = NSUUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        type = unboxer.unbox(key: "type")
        value = unboxer.unbox(key: "value")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    open func encode(with aCoder: NSCoder) {
        
    }
    
    open static var supportsSecureCoding: Bool {
        return true
    }
    
}
