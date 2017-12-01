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
    open var ethnicity: String?
    open var race: String?
    open var build: String?
    open var hairColour: String?
    open var eyeColour: String?
    open var marks: [String]?
    open var remarks: String?
    
    open var imageThumbnail: Media?
    open var image: Media?
    
    open static var supportsSecureCoding: Bool { return true }
    open static var modelVersion: Int { return 0 }
    
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
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
        ethnicity = unboxer.unbox(key: "ethnicity")
        race = unboxer.unbox(key: "race")
        build = unboxer.unbox(key: "build")
        hairColour = unboxer.unbox(key: "hairColour")
        eyeColour = unboxer.unbox(key: "eyeColour")
        marks = unboxer.unbox(key: "identifyingMarks")
        remarks = unboxer.unbox(key: "remarks")
        imageThumbnail = unboxer.unbox(key: "imageThumbnail")
        image = unboxer.unbox(key: "image")
        
        super.init()
    }
    
    public required init(id: String = UUID().uuidString) {
        self.id = id
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!
        
        super.init()
        
        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)
        
        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        height = aDecoder.decodeInteger(forKey: CodingKey.height.rawValue)
        weight = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.weight.rawValue) as String?
        ethnicity = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.ethnicity.rawValue) as String?
        race = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.race.rawValue) as String?
        build = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.build.rawValue) as String?
        hairColour = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.hairColour.rawValue) as String?
        eyeColour = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.eyeColour.rawValue) as String?
        marks = aDecoder.decodeObject(of: NSArray.self, forKey: CodingKey.marks.rawValue) as? [String]
        remarks = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.remarks.rawValue) as String?

        imageThumbnail = aDecoder.decodeObject(of: Media.self, forKey: CodingKey.imageThumbnail.rawValue)
        image = aDecoder.decodeObject(of: Media.self, forKey: CodingKey.entityType.rawValue)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(PersonDescription.modelVersion, forKey: CodingKey.version.rawValue)

        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        aCoder.encode(height, forKey: CodingKey.height.rawValue)
        aCoder.encode(weight, forKey: CodingKey.weight.rawValue)
        aCoder.encode(ethnicity, forKey: CodingKey.ethnicity.rawValue)
        aCoder.encode(race, forKey: CodingKey.race.rawValue)
        aCoder.encode(build, forKey: CodingKey.build.rawValue)
        aCoder.encode(hairColour, forKey: CodingKey.hairColour.rawValue)
        aCoder.encode(eyeColour, forKey: CodingKey.eyeColour.rawValue)
        aCoder.encode(marks, forKey: CodingKey.marks.rawValue)
        aCoder.encode(remarks, forKey: CodingKey.remarks.rawValue)

        aCoder.encode(imageThumbnail, forKey: CodingKey.imageThumbnail.rawValue)
        aCoder.encode(image, forKey: CodingKey.image.rawValue)
    }
    
    public func formatted() -> String? {
        var formattedComponents: [String] = []

        if let height = height {
            formattedComponents.append("\(height) cm")
        }

        if let weight = weight?.ifNotEmpty() {
            formattedComponents.append("\(weight) kg")
        }

        if let ethnicity = ethnicity?.ifNotEmpty() {
            formattedComponents.append("\(ethnicity)")
        }

        if let race = race?.ifNotEmpty() {
            formattedComponents.append("\(race)")
        }

        if let build = build?.ifNotEmpty() {
            formattedComponents.append("\(build)" + " build")
        }

        if let hairColour = hairColour?.ifNotEmpty()?.localizedLowercase {
            formattedComponents.append("\(hairColour) hair")
        }

        if let eyeColour = eyeColour?.ifNotEmpty() {
            formattedComponents.append(eyeColour.localizedLowercase + " eyes")
        }

        if let marks = marks {
            formattedComponents.append(marks.joined(separator: ", "))
        }

        if let remarks = remarks?.ifNotEmpty() {
            formattedComponents.append(remarks.localizedLowercase)
        }
        
        if formattedComponents.isEmpty {
            return nil
        }

        return formattedComponents.joined(separator: ", ")
    }

    private enum CodingKey: String {
        case version
        case id
        case dateCreated
        case dateUpdated
        case createdBy
        case updatedBy
        case effectiveDate
        case expiryDate
        case entityType
        case isSummary
        case source

        case height
        case weight
        case ethnicity
        case race
        case build
        case hairColour
        case eyeColour
        case marks
        case remarks
        case imageThumbnail
        case image
    }

}
