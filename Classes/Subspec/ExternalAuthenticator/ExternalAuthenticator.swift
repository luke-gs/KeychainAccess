//
//  ExternalAuthenticator.swift
//  MPOLKit
//
//  Created by Herli Halim on 10/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import SafariServices
import PromiseKit

public final class ExternalAuthenticator<T: AuthenticationProvider> {

    private var safariViewController: SFSafariViewController? = nil
    private var pendingPromiseResult: Promise<T.Result>.PendingTuple? = nil

    public let authenticationProvider: T

    public var useSafariViewController: Bool

    /// Initialise the ExternalAuthenticator.
    ///
    /// - Parameters:
    ///   - authenticationProvider: The AuthenticationProvider conformant.
    ///   - useSafariViewController: Whether the authentication will be facilitated through SFSafariViewController.
    ///                              Defaults to `true`. If this value is `false`, Safari will be used.
    public init(authenticationProvider: T, useSafariViewController: Bool = true) {
        self.authenticationProvider = authenticationProvider
        self.useSafariViewController = useSafariViewController
    }

    /// Starts the authentication workflow by redirecting to the provider's website.
    ///
    /// - Parameter authenticationProvider: The authentication provider to be used.
    /// - Returns: A promise with the result returned by the provider. The promise will throw cancelled error in 180 secs.
    public func authenticate() -> Promise<T.Result> {

        let scheme = authenticationProvider.urlScheme
        precondition(Bundle.main.containsURLScheme(scheme), "\(scheme) is not registered in the Info.plist")

        let pendingTuple: Promise<T.Result>.PendingTuple = Promise.pending()
        self.pendingPromiseResult = pendingTuple

        presentAuthentication(authenticationProvider.authorizationURL)

        let timeout: Promise<T.Result> = after(seconds: 180).then { throw NSError.cancelledError() }
    
        return race(pendingTuple.promise, timeout)
    }

    /// The `UIApplication.application:openURL:options:` handler.
    ///
    /// - Parameters:
    ///   - app: The app passed in by the UIApplication callback.
    ///   - url: The url passed in by the UIApplication callback.
    ///   - options: The options passed in by the UIApplication callback.
    /// - Important:
    ///   This relies on `UIApplication.application:openURL:options:` to be passed in to work. Without
    ///   the promise isn't be fulfillable.
    /// - Returns: true if the the passed in `url.scheme` successfully handled the request or false if the url is not
    ///            intended for this authenticator.
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {

        if let safariViewController = safariViewController {
            safariViewController.dismiss(animated: true, completion: nil)
            self.safariViewController = nil
        }

        // Not intended for this authenticator, return `false`.
        guard authenticationProvider.canHandleURL(url) else {
            return false
        }

        // Shouldn't happen?
        guard let pending = pendingPromiseResult else {
            return false
        }

        let result = authenticationProvider.authenticationLinkResult(url)
        result.then {
            pending.fulfill($0)
        }.catch {
            pending.reject($0)
        }

        self.pendingPromiseResult = nil

        return true
    }

    // MARK: - Private Utilities

    private func presentAuthentication(_ url: URL) {

        if useSafariViewController {
            let safariViewController = SFSafariViewController(url: url)
            var topController = UIApplication.shared.keyWindow?.rootViewController
            while let vc = topController?.presentedViewController {
                topController = vc
            }
            topController?.present(safariViewController, animated: true, completion: nil)
            self.safariViewController = safariViewController
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] success in
                if !success {
                    if let pending = self?.pendingPromiseResult {
                        pending.reject(NSError.cancelledError())
                    }
                }
            })
        }

    }

}
