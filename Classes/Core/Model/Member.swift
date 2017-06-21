//
//  Member.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

// Officer object, consolidate them later.
open class Member: NSObject, Serialisable {

    open let id: String
    open var rank: String?
    open var stationCode: String?
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "registeredId") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        rank = unboxer.unbox(key: "rank")
        stationCode = unboxer.unbox(key: "stationCode")
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
