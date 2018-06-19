//
//  PickableManifestEntry.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Utility ManifestEntry wrapper class that conforms to Pickable
/// Note: we don't just make Manifest Entry conform to Pickable due to different meaning of 'title' property.
open class PickableManifestEntry: Pickable {

    public let entry: ManifestEntry

    public init(_ entry: ManifestEntry) {
        self.entry = entry
    }

    open var title: String? {
        // Title of manifest item is the title of the drop down list in the portal, not displayed in app
        // We use rawValue here as that is display text of this particular item
        return entry.rawValue
    }

    open var subtitle: String? {
        // Subtitle of manifest item is the title of the sub category, not displayed in app
        return nil
    }
}
