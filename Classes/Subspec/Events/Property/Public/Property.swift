//
//  Property.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public typealias PropertyDetail = (title: String, type: PropertyDetailsType)

public enum PropertyDetailsType {
    case text
    case picker(options: [String])
}

public struct Property {
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
}

