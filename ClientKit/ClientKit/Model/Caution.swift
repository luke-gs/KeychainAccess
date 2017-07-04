//
//  Caution.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

@objc(MPLCaution)
open class Caution: NSObject, Serialisable {

    open let id : String
    open var type: String?
    open var issuingOrganisationalUnit: String?
    open var processedDate: Date?
    open var cautionDescription: String?
    
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
        
        type = unboxer.unbox(key: "cautionType")
        issuingOrganisationalUnit = unboxer.unbox(key: "issuingOrganisationalUnit")
        processedDate = unboxer.unbox(key: "processedDate", formatter: Caution.dateTransformer)
        cautionDescription = unboxer.unbox(key: "description")
        
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
