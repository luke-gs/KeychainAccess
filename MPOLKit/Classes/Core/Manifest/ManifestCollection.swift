//
//  ManifestCollection.swift
//  VCom
//
//  Created by Rod Brown on 30/10/16.
//  Copyright © 2016 Gridstone. All rights reserved.
//


/// A ManifestCollection represents a grouping of manifest items with the Manifest.
///
/// Each manifest item has a "collection" property which is a string value. These can
/// be any string a user wishes to add within the manifest on the MPOL Portal, but
/// there are a set of defined cases that are expected within a manifest, as defined
/// by Gridstone.
/// 
/// To ensure applications only use strings that are specifically known to be "Manifest
/// Collections", you should use the ManifestCollection type. Applications which have
/// their own specific types can extend ManifestCollection, and define new types.
/// 
/// Creating ManifestCollections on the fly, e.g.:
///
///     manifest.entries(for: ManifestCollection(rawValue: "randomString))
///
/// is strongly discouraged. You should declare the Collection explicitly, and then use
/// it in your code.
public struct ManifestCollection: RawRepresentable, Equatable, Hashable {
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public let rawValue: String
    
    static let States     = ManifestCollection(rawValue: "states")
    static let Genders    = ManifestCollection(rawValue: "genders")
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

public func ==(lhs: ManifestCollection, rhs: ManifestCollection) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
