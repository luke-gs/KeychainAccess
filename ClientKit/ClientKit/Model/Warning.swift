//
//  Warning.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox
import MPOLKit

@objc(MPLWarning)
open class Warning: NSObject, Serialisable {
    
    open let id: String
    open var creationDate: Date?
    open var category: String?
    open var type: String?
    open var warningDescription: String?
    
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
        creationDate = unboxer.unbox(key: "creationDate", formatter: Warning.dateTransformer)
        category = unboxer.unbox(key: "category")
        type = unboxer.unbox(key: "type")
        warningDescription = unboxer.unbox(key: "description")
        
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
