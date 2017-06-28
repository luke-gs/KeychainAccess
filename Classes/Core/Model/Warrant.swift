//
//  Warrant.swift
//  MPOLKit
//
//  Created by Herli Halim on 19/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Unbox

@objc(MPLWarrant)
open class Warrant: NSObject, Serialisable {
    
    open let id: String
    open var warrantDescription: String?
    open var type: String?
    open var issueDate: Date?
    
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
        type = unboxer.unbox(key: "type")
        warrantDescription = unboxer.unbox(key: "description")
        issueDate = unboxer.unbox(key: "issueDate", formatter: Warrant.dateTransformer)
        
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
