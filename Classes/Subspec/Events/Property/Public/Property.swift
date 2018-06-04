//
//  Property.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public typealias PropertyDetail = (title: String, type: PropertyDetailsType)

// TODO: Expand on these types depending on designs
public enum PropertyDetailsType {
    case text
    case picker(options: [String])
}

// TODO: Either make this a class or a protocol to be overriden/extend in the app
public struct Property: Equatable {
    private var id: String = UUID().uuidString
    public var type: String
    public var subType: String?
    public var detailNames: [PropertyDetail]?

    public var fullType : String {
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

