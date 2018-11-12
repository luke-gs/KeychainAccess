//
//  Property.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

// TODO: Expand on these types depending on designs
public enum PropertyDetailsType: Codable {
    case text
    case picker(options: [String])

    private enum CodingKeys: CodingKey {
        case pickerOptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let pickerValue =  try container.decode([String].self, forKey: .pickerOptions)
            self = .picker(options: pickerValue)
        } catch {
            self = .text
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .picker(let value):
            try container.encode(value, forKey: .pickerOptions)
        default:
            break
        }
    }
}

public struct PropertyDetail: Codable {
    public var title: String
    public var type: PropertyDetailsType

    public init(title: String, type: PropertyDetailsType) {
        self.title = title
        self.type = type
    }
}

// TODO: Either make this a class or a protocol to be overriden/extend in the app
public struct Property: Codable, Equatable {
    private var id: String = UUID().uuidString
    public var type: String
    public var subType: String?
    public var detailNames: [PropertyDetail]?

    public var fullType: String {
        return [type, subType].joined(separator: " - ")
    }

    public init(type: String, subType: String, detailNames: [PropertyDetail]? = nil) {
        self.type = type
        self.subType = subType
        self.detailNames = detailNames
    }

    public static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.id == rhs.id
    }
}
