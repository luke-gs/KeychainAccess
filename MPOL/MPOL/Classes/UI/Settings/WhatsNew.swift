//
//  WhatsNew.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Foundation

public struct WhatsNew {

    // Update version when updating whats new content
    public static let version = "1.1"

    public static let detailItems = [
        WhatsNewDetailItem(image: #imageLiteral(resourceName: "WhatsNew"), title: "What's New",
                           detail: """
                                [MPOLA-1584] - Update Login screen to remove highlighting in T&Cs and forgot password.
                                [MPOLA-1565] - Use manifest for event entity relationships.
                                [MPOLA-1568] - Pin the logout button to the bottom
                                [MPOLA-1597] - Update presentation for Terms and Conditions from Settings
                                [MPOLA-1597] - Update presentation for What's New from Settings
                                [MPOLA-1597] - Add basic signature capture from Settings
                            """)

    ]
}
