//
//  Template.swift
//  MPOLKit
//
//  Created by Kara Valentine on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

///  Base template class. Extend this for your own templates!
///  Overrides equality behaviour for set comparison reasons.
public class Template: Hashable, Codable {
    public let id: String
    public let timestamp: Date

    public var hashValue: Int {
        return id.hashValue
    }

    // disallow initialising base templates
    internal init(id: String = UUID().uuidString, timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
    }

    // overrides default behaviour for set comparisons
    public static func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.id == rhs.id
    }
}
