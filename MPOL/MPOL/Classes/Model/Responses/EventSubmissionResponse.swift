//
//  EventSubmissionResponse.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Unbox

private enum Coding: String {
    case id = "id"
    case eventNumber = "eventNumber"
}

public class EventSubmissionResponse: MPOLKitEntity {

    // MARK: - Class

    public override class var serverTypeRepresentation: String {
        return "event"
    }

    // MARK: - Properties

    public var eventNumber: Int

    // MARK: Unboxable

    public required init(unboxer: Unboxer) throws {
        eventNumber = try unboxer.unbox(key: "eventNumber")

        try super.init(unboxer: unboxer)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case eventNumber
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventNumber = try container.decode(Int.self, forKey: .eventNumber)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventNumber, forKey: CodingKeys.eventNumber)
    }
}

extension EventSubmissionResponse: EventSubmittable {

    // MARK: EventSubmittable
    public var title: String {
        return "Event Submitted"
    }

    public var detail: String {
        return "PSCORE-00\(eventNumber)"
    }
}
