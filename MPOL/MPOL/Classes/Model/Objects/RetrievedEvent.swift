//
//  RetrievedEvent.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import Unbox

// Event is already taken...
@objc(MPLRetrievedEvent)
open class RetrievedEvent: Entity {

    // MARK: - Properties

    open var eventDescription: String?
    open var name: String?
    open var occurredDate: Date?
    open var type: String?

    // MARK: - Unboxable

    public required init(unboxer: Unboxer) throws {
        name = unboxer.unbox(key: CodingKeys.name.rawValue)
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        eventDescription = unboxer.unbox(key: CodingKeys.eventDescription.rawValue)
        occurredDate = unboxer.unbox(key: CodingKeys.occurredDate.rawValue, formatter: ISO8601DateTransformer.shared)

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case eventDescription = "description"
        case name
        case occurredDate = "occurred"
        case type = "eventType"
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard !dataMigrated else { return }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        occurredDate = try container.decodeIfPresent(Date.self, forKey: .occurredDate)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventDescription, forKey: CodingKeys.eventDescription)
        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(occurredDate, forKey: CodingKeys.occurredDate)
        try container.encode(type, forKey: CodingKeys.type)
    }

}
