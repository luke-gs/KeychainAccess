//
//  EventSubmissionResponse.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit
import Unbox

private enum Coding: String {
    case id = "id"
    case eventNumber = "eventNumber"
}

public class EventSubmissionResponse: MPOLKitEntityProtocol {
    public static var serverTypeRepresentation: String = "Event"
    public static var supportsSecureCoding: Bool = true

    public var id: String = UUID().uuidString
    public var eventNumber: Int

    public func isEssentiallyTheSameAs(otherEntity: MPOLKitEntityProtocol) -> Bool {
        return otherEntity.id == self.id
    }

    // MARK: Codable
    required public init?(coder aDecoder: NSCoder) {
        eventNumber = aDecoder.decodeInteger(forKey: Coding.eventNumber.rawValue)
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(eventNumber, forKey: Coding.eventNumber.rawValue)
        aCoder.encode(id, forKey: Coding.id.rawValue)
    }

    // MARK: Unboxable
    public required init(unboxer: Unboxer) throws {
        eventNumber = try unboxer.unbox(key: "eventNumber")
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
