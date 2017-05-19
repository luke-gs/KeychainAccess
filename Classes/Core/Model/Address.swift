//
//  Address.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class Address: NSObject, Serialisable {


    open let id : String
    
    open var commonName : String?
    open var country : String?
    
    open var floor : String?
    
    open var postcode : String?
    
    open var state : String?
    open var streetDirectional : String?
    open var streetName : String?
    open var streetNumber : String?
    open var streetType : String?
    open var suburb : String?
    open var unitNumber : String?
    
    public required init(id: String = NSUUID().uuidString) {
        self.id = id
    }

    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        
        commonName = unboxer.unbox(key: "commonName")
        country = unboxer.unbox(key: "country")
        floor = unboxer.unbox(key: "floor")
        postcode = unboxer.unbox(key: "postcode")
        state = unboxer.unbox(key: "state")
        streetDirectional = unboxer.unbox(key: "streetDirectional")
        streetName = unboxer.unbox(key: "streetName")
        streetType = unboxer.unbox(key: "streetType")
        suburb = unboxer.unbox(key: "suburb")
        unitNumber = unboxer.unbox(key: "unitNumber")
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
