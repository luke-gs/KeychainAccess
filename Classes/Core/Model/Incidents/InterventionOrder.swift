//
//  InterventionOrder.swift
//  MPOLKit
//
//  Created by Herli Halim on 21/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

class InterventionOrder: NSObject, Serialisable {

    open let id: String
    
    open var servedDate: Date?
    open var respondentName: String?
    open var type: String?
    open var complainants: [NSObject]?
    open var conditions: [NSObject]?
    open var status: String?
    open var respondentDateOfBirth: Date?
    open var address: String?
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        self.id = id
        
        servedDate = unboxer.unbox(key: "orderServed", formatter: InterventionOrder.dateTransformer)
        respondentName = unboxer.unbox(key: "respondentName")
        type = unboxer.unbox(key: "orderType")
        complainants = unboxer.unbox(key: "complainants")
        conditions = unboxer.unbox(key: "conditions")
        status = unboxer.unbox(key: "status")
        respondentDateOfBirth = unboxer.unbox(key: "respondentDateOfBirth", formatter: InterventionOrder.dateTransformer)
        address = unboxer.unbox(key: "orderAddress")
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
