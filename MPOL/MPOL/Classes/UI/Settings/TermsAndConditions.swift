//
//  TermsAndConditions.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public struct TermsAndConditions {

    // Update version when updating terms and conditions content
    public static let version = "1.0"

    public static var url: URL {

        if let url = Bundle.main.url(forResource: "termsandconditions", withExtension: "html") {
            return url
        }

        fatalError("termsAndConditions file not found ")
    }
}
