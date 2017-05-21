//
//  Licence.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

@objc(MPLLicence)
open class Licence: NSObject, Serialisable {

    open let id : String
    
    open var number: String?
    open var state: String?
    open var country: String?
    open var effectiveFromDate: Date?
    open var effectiveToDate: Date?
    open var status: String?
    

    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared
    
    public required init(unboxer: Unboxer) throws {
        
        guard let id: String = unboxer.unbox(key: "id") else {
            throw ParsingError.missingRequiredField
        }
        
        self.id = id
        
        number = unboxer.unbox(key: "licenceNumber")
    
        country = unboxer.unbox(key: "country")
        state = unboxer.unbox(key: "state")
        status = unboxer.unbox(key: "status")
        
        effectiveFromDate = unboxer.unbox(key: "effectiveDate", formatter: Licence.dateTransformer)
        effectiveToDate = unboxer.unbox(key: "expiryDate", formatter: Licence.dateTransformer)
        
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
