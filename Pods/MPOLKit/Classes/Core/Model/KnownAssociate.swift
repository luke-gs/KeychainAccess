//
//  KnownAssociate.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

@objc(MPLKnownAssociate)
open class KnownAssociate: NSObject, Serialisable {

    open let id : String
    open var fullName: String?
    open var dateOfBirth: Date?
    open var knownAssociateDescription: String?
    
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
        fullName = unboxer.unbox(key: "fullName")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: KnownAssociate.dateTransformer)
        knownAssociateDescription = unboxer.unbox(key: "description")
        
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
