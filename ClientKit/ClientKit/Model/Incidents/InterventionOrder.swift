//
//  InterventionOrder.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit
import Unbox

open class InterventionOrder: Event {
    
    open var servedDate: Date?
    open var type: String?
    
    open var respondentName: String?
    open var complainants: [NSObject]?
    open var conditions: [NSObject]?
    open var respondentDateOfBirth: Date?
    open var address: String?
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        try super.init(unboxer: unboxer)
        
        servedDate = unboxer.unbox(key: "orderServed", formatter: InterventionOrder.dateTransformer)
        respondentName = unboxer.unbox(key: "respondentName")
        type = unboxer.unbox(key: "orderType")
        complainants = unboxer.unbox(key: "complainants")
        conditions = unboxer.unbox(key: "conditions")
        respondentDateOfBirth = unboxer.unbox(key: "respondentDateOfBirth", formatter: InterventionOrder.dateTransformer)
        address = unboxer.unbox(key: "orderAddress")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public required init(id: String) {
        super.init(id: id)
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        MPLUnimplemented()
    }
}
