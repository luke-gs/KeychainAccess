//
//  EventType.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// A bunch of event types
/// This can later be expanded upon to build different types of events
/// via the app
public struct EventType: RawRepresentable, Hashable {

    //Define default EventTypes
    public static let blank = EventType(rawValue: "blank")

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public static func ==(lhs: EventType, rhs: EventType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

