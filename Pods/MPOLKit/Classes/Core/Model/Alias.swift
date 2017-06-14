//
//  Alias.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Foundation
import Unbox


@objc(MPLAlias)
open class Alias: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    open var id: String
    
    open var firstName: String?
    open var lastName: String?
    open var sex: String?
    open var dateOfBirth: Date?
    open var type: String?
    
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
        firstName = unboxer.unbox(key: "firstName")
        lastName = unboxer.unbox(key: "lastName")
        sex = unboxer.unbox(key: "sex")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Alias.dateTransformer)
        type = unboxer.unbox(key: "type")
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    public func encode(with aCoder: NSCoder) {
        fatalError("Not implemented yet")
    }
    
    
    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""
        
        if let lastName = self.lastName?.ifNotEmpty() {
            formattedName = lastName
            
            if firstName?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.firstName?.ifNotEmpty() {
            formattedName += givenName
            
        }
        
        return formattedName
    }
    
}
