//
//  Interest.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

open class Interest: NSObject, Serialisable {

    open let id: String
    
    open var summary: String?
    open var remarks: String?
    open var warningCategory: String?
    open var warningType: String?
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        
        summary = unboxer.unbox(key: "summary")
        remarks = unboxer.unbox(key: "remarks")
        warningCategory = unboxer.unbox(key: "warningCategory")
        warningType = unboxer.unbox(key: "warningType")
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
