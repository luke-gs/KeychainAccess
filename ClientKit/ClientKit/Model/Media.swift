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
    
    public class var supportsSecureCoding: Bool {
        return true
    }
    
    open let id: String

    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var createdBy: String?
    open var updatedBy: String?
    open var effectiveDate: Date?
    open var expiryDate: Date?
    open var entityType: String?
    open var isSummary: Bool?
    
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
        isSummary     = unboxer.unbox(key: "isSummary")
        
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
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? else {
            return nil
        }
        
        self.id = id
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    
}
