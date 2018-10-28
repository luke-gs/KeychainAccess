//
//  Media.swift
//  MPOL
//
//  Created by RUI WANG on 12/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

@objc(MPLMedia)
open class Media: IdentifiableDataModel {

    // MARK: - Class

    open class var serverTypeRepresentation: String {
        return "media"
    }

    // MARK: - Properties

    open var createdBy: String?
    open var dateCreated: Date?
    open var dateUpdated: Date?
    open var effectiveDate: Date?
    open var entityType: String?
    open var expiryDate: Date?
    open var height: Double = 0
    open var isSummary: Bool = false
    open var mediaDescription: String?
    open var mimeType: String?
    open var name: String?
    open var source: MPOLSource?
    open var updatedBy: String?
    open var uri: URL?
    open var width: Double = 0

    // MARK: - Unboxable

    private static let dateTransformer: ISO8601DateTransformer = ISO8601DateTransformer.shared

    public required init(unboxer: Unboxer) throws {
        dateCreated   = unboxer.unbox(key: "dateCreated", formatter: Media.dateTransformer)
        dateUpdated   = unboxer.unbox(key: "dateLastUpdated", formatter: Media.dateTransformer)
        createdBy     = unboxer.unbox(key: "createdBy")
        updatedBy     = unboxer.unbox(key: "updatedBy")
        effectiveDate = unboxer.unbox(key: "effectiveDate", formatter: Media.dateTransformer)
        expiryDate    = unboxer.unbox(key: "expiryDate", formatter: Media.dateTransformer)
        entityType    = unboxer.unbox(key: "entityType")
        isSummary     = unboxer.unbox(key: "isSummary") ?? false

        mimeType      = unboxer.unbox(key: "mimeType")
        uri           = unboxer.unbox(key: "url")
        name          = unboxer.unbox(key: "name")
        width         = unboxer.unbox(key: "width") ?? 0.0
        height        = unboxer.unbox(key: "height") ?? 0.0
        source        = unboxer.unbox(key: "source")
        mediaDescription = unboxer.unbox(key: "description")

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case createdBy
        case dateCreated
        case dateUpdated
        case effectiveDate
        case entityType
        case expiryDate
        case height
        case isSummary
        case mediaDescription
        case mimeType
        case name
        case source
        case updatedBy
        case uri
        case width
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dateUpdated = try container.decodeIfPresent(Date.self, forKey: .dateUpdated)
        effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
        entityType = try container.decodeIfPresent(String.self, forKey: .entityType)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        height = try container.decode(Double.self, forKey: .height)
        isSummary = try container.decode(Bool.self, forKey: .isSummary)
        mediaDescription = try container.decodeIfPresent(String.self, forKey: .mediaDescription)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        source = try container.decodeIfPresent(MPOLSource.self, forKey: .source)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        uri = try container.decodeIfPresent(URL.self, forKey: .uri)
        width = try container.decode(Double.self, forKey: .width)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdBy, forKey: CodingKeys.createdBy)
        try container.encode(dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(dateUpdated, forKey: CodingKeys.dateUpdated)
        try container.encode(effectiveDate, forKey: CodingKeys.effectiveDate)
        try container.encode(entityType, forKey: CodingKeys.entityType)
        try container.encode(expiryDate, forKey: CodingKeys.expiryDate)
        try container.encode(height, forKey: CodingKeys.height)
        try container.encode(isSummary, forKey: CodingKeys.isSummary)
        try container.encode(mediaDescription, forKey: CodingKeys.mediaDescription)
        try container.encode(mimeType, forKey: CodingKeys.mimeType)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(source, forKey: CodingKeys.source)
        try container.encode(updatedBy, forKey: CodingKeys.updatedBy)
        try container.encode(uri, forKey: CodingKeys.uri)
        try container.encode(width, forKey: CodingKeys.width)
    }

}
