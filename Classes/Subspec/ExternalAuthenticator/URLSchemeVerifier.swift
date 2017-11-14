//
//  URLSchemeVerifier.swift
//  MPOLKit
//
//  Created by Herli Halim on 14/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public class URLSchemeVerifier {

    /// Verify that the specified scheme is registered/added in the main Info.plist.
    ///
    /// - Parameter scheme: The scheme to be verified.
    /// - Returns: A bool value to indicate that the scheme is registered correectly.
    public static func verifyRegisteredURLScheme(_ scheme: String) -> Bool {

        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
            return false
        }

        let urlSchemes = urlTypes.flatMap({($0["CFBundleURLSchemes"] as? [String])?.first })

        return urlSchemes.contains(scheme)
    }

}
