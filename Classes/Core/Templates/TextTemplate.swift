//
//  TextTemplate.swift
//  MPOLKit
//
//  Created by Kara Valentine on 19/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Sample Template subclass that provides a name, description and value.
/// Demonstrates one way of implementing encoding/decoding.
public class TextTemplate: Template {
    public let name: String
    public let description: String
    public let value: String

    public enum CodingKeys: String, CodingKey {
        case name
        case description
        case value
        case id
        case timestamp
    }

    public init(name: String, description: String, value: String, id: String = UUID().uuidString, timestamp: Date = Date()) {
        self.name = name
        self.description = description
        self.value = value
        super.init(id: id, timestamp: timestamp)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.value = try container.decode(String.self, forKey: .value)
        super.init(id: try! container.decode(String.self, forKey: .id), timestamp: try container.decode(Date.self, forKey: .timestamp))
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(value, forKey: .value)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
