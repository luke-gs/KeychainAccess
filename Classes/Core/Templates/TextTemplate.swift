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
        let keys: [CodingKeys] = [.name, .description, .value, .id]
        let data = try keys.map { key in
            try container.decode(Data.self, forKey: key)
        }

        // can't call our other init here :(
        self.name = String(data: data[0], encoding: .ascii)!
        self.description = String(data: data[1], encoding: .ascii)!
        self.value = String(data: data[2], encoding: .ascii)!
        super.init(id: String(data: data[3], encoding: .ascii)!, timestamp: try container.decode(Date.self, forKey: .timestamp))
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let nameData = name.data(using: .ascii)
        let descriptionData = description.data(using: .ascii)
        let valueData = value.data(using: .ascii)
        let idData = id.data(using: .ascii)
        try container.encode(nameData, forKey: .name)
        try container.encode(descriptionData, forKey: .description)
        try container.encode(valueData, forKey: .value)
        try container.encode(idData, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
