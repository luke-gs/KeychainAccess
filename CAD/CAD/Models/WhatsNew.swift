//
//  WhatsNew.swift
//  CAD
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct WhatsNew {

    // Update version when updating whats new content
    public static let version = "1.0"

    public static let detailItems = [
        WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
                           detail: """
                                Swipe through and discover the new features and updates that have been included in this release.
                                Refer to the release summary for full update notes.
                            """)

    ]
}
