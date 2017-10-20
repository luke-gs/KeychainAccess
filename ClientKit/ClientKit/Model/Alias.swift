//
//  Alias.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Foundation
import MPOLKit
import Unbox


@objc(MPLAlias)
open class Alias: NSObject, Serialisable {
    
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    open var id: String
    
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    open var source: MPOLSource?
    
    open var type: String?
    open var firstName: String?
    open var lastName: String?
    open var middleNames: String?
    open var dateOfBirth: Date?
    open var ethnicity: String?
    open var title: String?
    
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
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: Alias.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: Alias.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Alias.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: Alias.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary")
        source = unboxer.unbox(key: "source")

        type = unboxer.unbox(key: "nameType")
        firstName = unboxer.unbox(key: "givenName")
        middleNames = unboxer.unbox(key: "middleNames")
        lastName = unboxer.unbox(key: "familyName")
        dateOfBirth = unboxer.unbox(key: "dateOfBirth", formatter: Alias.dateTransformer)
        ethnicity = unboxer.unbox(key: "ethnicity")
        title = unboxer.unbox(key: "title")
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    // TEMP?
    open var formattedName: String? {
        var formattedName: String = ""
        
        if let lastName = self.lastName?.ifNotEmpty() {
            formattedName += lastName
            
            if firstName?.isEmpty ?? true == false || middleNames?.isEmpty ?? true == false {
                formattedName += ", "
            }
        }
        if let givenName = self.firstName?.ifNotEmpty() {
            formattedName += givenName
            
            if middleNames?.isEmpty ?? true == false {
                formattedName += " "
            }
        }
        
        if let firstMiddleNameInitial = middleNames?.first {
            formattedName.append(firstMiddleNameInitial)
            formattedName += "."
        }
        
        return formattedName

    }
    
}
