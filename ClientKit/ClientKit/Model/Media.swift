//
//  Media.swift
//  ClientKit
//
//  Created by RUI WANG on 12/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import Unbox

open class Media: NSObject, Serialisable {
    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    open class var serverTypeRepresentation: String {
        return "media"
    }
    
    open class var supportsSecureCoding: Bool { return true }

    open static var modelVersion: Int { return 0 }

    open let id: String

    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool = false
    
    open var mimeType: String?
    open var uri: URL?
    open var name: String?
    open var mediaDescription: String?
    open var width: Double?
    open var height: Double?
    
    open var source: MPOLSource?

    
    public required init(unboxer: Unboxer) throws {
        id            = unboxer.unbox(key: "id") ?? UUID().uuidString
        dateCreated   = unboxer.unbox(key: "dateCreated", formatter: Media.dateTransformer)
        dateUpdated   = unboxer.unbox(key: "dateLastUpdated", formatter: Media.dateTransformer)
        createdBy     = unboxer.unbox(key: "createdBy")
        updatedBy     = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Media.dateTransformer)
        expiryDate    = unboxer.unbox(key: "expiryDate", formatter: Media.dateTransformer)
        entityType    = unboxer.unbox(key: "entityType")
        isSummary     = unboxer.unbox(key: "isSummary") ?? false
        
        mimeType      = unboxer.unbox(key: "mimeType")
        uri           = unboxer.unbox(key: "uri")
        name          = unboxer.unbox(key: "name")
        width         = unboxer.unbox(key: "width")
        height        = unboxer.unbox(key: "height")
        source        = unboxer.unbox(key: "source")
        mediaDescription = unboxer.unbox(key: "description")

        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.id.rawValue) as String!
        isSummary = aDecoder.decodeBool(forKey: CodingKey.isSummary.rawValue)
        
        super.init()

        dateCreated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateCreated.rawValue) as Date?
        dateUpdated = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.dateUpdated.rawValue) as Date?
        effectiveDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.effectiveDate.rawValue) as Date?
        expiryDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKey.expiryDate.rawValue) as Date?
        createdBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.createdBy.rawValue) as String?
        updatedBy = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.updatedBy.rawValue) as String?
        entityType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.entityType.rawValue) as String?

        if let source = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.source.rawValue) as String? {
            self.source = MPOLSource(rawValue: source)
        }

        mimeType = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.mimeType.rawValue) as String?
        uri = aDecoder.decodeObject(of: NSURL.self, forKey: CodingKey.uri.rawValue) as URL?
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.name.rawValue) as String?
        mediaDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKey.mediaDescription.rawValue) as String?
        height = aDecoder.decodeDouble(forKey: CodingKey.height.rawValue)
        width = aDecoder.decodeDouble(forKey: CodingKey.width.rawValue)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(Media.modelVersion, forKey: CodingKey.version.rawValue)

        aCoder.encode(id, forKey: CodingKey.id.rawValue)
        aCoder.encode(dateCreated, forKey: CodingKey.dateCreated.rawValue)
        aCoder.encode(dateUpdated, forKey: CodingKey.dateUpdated.rawValue)
        aCoder.encode(expiryDate, forKey: CodingKey.expiryDate.rawValue)
        aCoder.encode(createdBy, forKey: CodingKey.createdBy.rawValue)
        aCoder.encode(updatedBy, forKey: CodingKey.updatedBy.rawValue)
        aCoder.encode(entityType, forKey: CodingKey.entityType.rawValue)
        aCoder.encode(isSummary, forKey: CodingKey.isSummary.rawValue)
        aCoder.encode(source?.rawValue, forKey: CodingKey.source.rawValue)

        aCoder.encode(mimeType, forKey: CodingKey.mimeType.rawValue)
        aCoder.encode(uri, forKey: CodingKey.uri.rawValue)
        aCoder.encode(name, forKey: CodingKey.name.rawValue)
        aCoder.encode(mediaDescription, forKey: CodingKey.mediaDescription.rawValue)
        aCoder.encode(height, forKey: CodingKey.height.rawValue)
        aCoder.encode(width, forKey: CodingKey.width.rawValue)
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

        case mimeType
        case uri
        case name
        case mediaDescription
        case height
        case width
    }
    
}
