//
//  PersonDescription.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/5/17.
//
//

import Unbox
import MPOLKit

@objc(MPLPersonDescription)
open class PersonDescription: NSObject, Serialisable {
    
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
    
    open var height: Int?
    open var weight: String?
    open var enthnicity: String?
    open var hairColour: String?
    open var eyeColour: String?
    open var remarks: String?
    
    open var imageThumbnail: Media?
    open var image: Media?
    
    open var reportDate: Date?
    
    open static var supportsSecureCoding: Bool { return true }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
//        guard let id: String = unboxer.unbox(key: "id") else {
//            throw ParsingError.missingRequiredField
//        }
//        self.id = id
        
        id = unboxer.unbox(key: "id") ?? UUID().uuidString
        
        dateCreated = unboxer.unbox(key: "dateCreated", formatter: PersonDescription.dateTransformer)
        dateUpdated = unboxer.unbox(key: "dateLastUpdated", formatter: PersonDescription.dateTransformer)
        createdBy = unboxer.unbox(key: "createdBy")
        updatedBy = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: PersonDescription.dateTransformer)
        expiryDate = unboxer.unbox(key: "expiryDate", formatter: PersonDescription.dateTransformer)
        entityType = unboxer.unbox(key: "entityType")
        isSummary = unboxer.unbox(key: "isSummary")
        source = unboxer.unbox(key: "source")
        
        height = unboxer.unbox(key: "height")
        weight = unboxer.unbox(key: "weight")
        enthnicity = unboxer.unbox(key: "enthnicity")
        hairColour = unboxer.unbox(key: "hairColour")
        eyeColour = unboxer.unbox(key: "eyeColour")
        remarks = unboxer.unbox(key: "remarks")
        imageThumbnail = unboxer.unbox(key: "imageThumbnail")
        image = unboxer.unbox(key: "image")

        reportDate = unboxer.unbox(key: "reportDate", formatter: ISO8601DateTransformer.shared)
        
        super.init()
    }
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public func encode(with aCoder: NSCoder) {
        MPLUnimplemented()
    }
    
    public func formatted() -> String? {
        var initialString = ""
        if let height = height {
            initialString = "\(height) cm "
        }

        if let weight = weight?.ifNotEmpty() {
            initialString += "\(weight) kg "
        }
        
        initialString = initialString.trimmingCharacters(in: .whitespaces)
        
        var formattedComponents: [String] = []
        
        if initialString.isEmpty == false {
            formattedComponents.append(initialString)
        }
        
        var hair = ""

        if let hairColour = hairColour?.ifNotEmpty() {
            hair += hairColour.localizedLowercase
            hair += " "
        }
        if hair.isEmpty == false {
            hair += "hair"
            formattedComponents.append(hair)
        }
        if let eyeColour = eyeColour?.ifNotEmpty() {
            formattedComponents.append(eyeColour.localizedLowercase + " eyes")
        }
        
        if let remarks = remarks?.ifNotEmpty() {
            formattedComponents.append(remarks.localizedLowercase + " remarks")
        }
        
        if formattedComponents.isEmpty {
            return nil
        }
        return formattedComponents.joined(separator: ", ")
    }
    
}
