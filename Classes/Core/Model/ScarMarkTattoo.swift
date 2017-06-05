//
//  ScarMarkTattoo.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

@objc(MPLScarMarkTattoo)
open class ScarMarkTattoo: NSObject, Serialisable {
    
    open let id: String
    open var type: String?
    open var location: String?
    open var smtDescription: String?
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        type = unboxer.unbox(key: "type")
        location = unboxer.unbox(key: "location")
        smtDescription = unboxer.unbox(key: "description")
        
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
    
}
