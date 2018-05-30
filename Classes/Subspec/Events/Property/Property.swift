//
//  Property.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public struct Property {
    public var type: String
    public var subType: String?
    public var detailNames: [String]?

    public var fullType : String {
        return [type, subType].joined(separator: " - ")
    }

    public init(type: String, subType: String, detailNames: [String]? = nil) {
        self.type = type
        self.subType = subType
        self.detailNames = detailNames
    }
}

public struct PropertyDisplayable: CustomSearchDisplayable {
    public var title: String?
    public var subtitle: String?
    public var section: String?
    public var image: UIImage?

    public init(property: Property) {
        title = property.fullType
        section = property.type
    }

    public func contains(_ searchText: String) -> Bool {
        return title?.contains(searchText) ?? false
    }
}
