//
//  Interest.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

open class Interest: Event {
    
//    open var summary: String?
    open var remarks: String?
    open var warningCategory: String?
    open var warningType: String?
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
//        summary = unboxer.unbox(key: "summary")
        remarks = unboxer.unbox(key: "remarks")
        warningCategory = unboxer.unbox(key: "warningCategory")
        warningType = unboxer.unbox(key: "warningType")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        MPLUnimplemented()
    }
    
}
