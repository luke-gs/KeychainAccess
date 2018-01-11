//
//  Template.swift
//  MPOLKit
//
//  Created by Kara Valentine on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//


///  Template struct. The primary data object in the Template system.
///  Overrides equality behaviour for set comparison reasons.
public struct Template: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }

    public init(name: String, description: String, value: String) {
        self.name = name
        self.description = description
        self.value = value
    }

    public let name: String
    public let description: String
    public let value: String

    // overrides default behaviour for set comparisons
    public static func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name
    }
}
