//
//  AuthenticationProvider.swift
//  MPOLKit
//
//  Created by Herli Halim on 10/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import PromiseKit

public protocol AuthenticationProvider {

    associatedtype Result

    /// The URL to begin the login process.
    var authorizationURL: URL { get }

    /// The URL app url scheme that this provider should handle.
    var urlScheme: String { get }

    /// Whether the provider could handle given callback
    ///
    /// - Parameter url: The callback URL that's triggered.
    /// - Returns: true if it's supported URL.
    func canHandleURL(_ url: URL) -> Bool
    
    /// The result of the authentication.
    ///
    /// - Parameter url: The callback URL that's triggered. This URL should contain the result returned in
    ///             query strings format.
    /// - Returns: A Promise to return the result with value of `Result` associatedtype.
    func authenticationLinkResult(_ url: URL) -> Promise<Result>

}
