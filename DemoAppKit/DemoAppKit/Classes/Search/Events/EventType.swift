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
public class EventType: ExtensibleKey<String> {

    // Define default EventTypes
    public static let blank = EventType("blank")
}

