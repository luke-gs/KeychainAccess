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

    open var name: String?
    open var type: String?

    open var eventDescription: String?
    open var occurredDate: Date?

    public required init(unboxer: Unboxer) throws {
        name = unboxer.unbox(key: CodingKeys.name.rawValue)
        type = unboxer.unbox(key: CodingKeys.type.rawValue)
        eventDescription = unboxer.unbox(key: CodingKeys.eventDescription.rawValue)
        occurredDate = unboxer.unbox(key: CodingKeys.occurred.rawValue, formatter: ISO8601DateTransformer.shared)

        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Check for archieved modelVersion and current version if data migration is required.
        name = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as String?
        type = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.type.rawValue) as String?
        eventDescription = aDecoder.decodeObject(of: NSString.self, forKey: CodingKeys.eventDescription.rawValue) as String?
        occurredDate = aDecoder.decodeObject(of: NSDate.self, forKey: CodingKeys.occurred.rawValue) as Date?
    }

    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)

        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(type, forKey: CodingKeys.type.rawValue)
        aCoder.encode(eventDescription, forKey: CodingKeys.eventDescription.rawValue)
        aCoder.encode(occurredDate, forKey: CodingKeys.occurred.rawValue)
    }

    // TODO: support codable
    required public init(from decoder: Decoder) throws {
        MPLUnimplemented()
    }

    open override class var modelVersion: Int {
        return 1
    }

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case eventDescription = "description"
        case type = "eventType"
        case occurred = "occurred"

        case version = "version"
    }
}
