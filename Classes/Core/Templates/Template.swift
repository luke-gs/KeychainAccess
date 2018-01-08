//
//  Template.swift
//  MPOLKit
//
//  Template struct. The primary data object in the Template system.
//  Overrides equality behaviour for set comparison reasons.
//
//  Created by Kara Valentine on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

public struct Template: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }

    init(name: String, description: String, value: String) {
        self.name = name
        self.description = description
        self.value = value
    }

    init(name: String) {
        self.name = name
        self.description = ""
        self.value = ""
    }

    let name: String
    let description: String
    let value: String

    // overrides default behaviour for set comparisons
    public static func ==(lhs: Template, rhs: Template) -> Bool {
        return lhs.name == rhs.name
    }
}
