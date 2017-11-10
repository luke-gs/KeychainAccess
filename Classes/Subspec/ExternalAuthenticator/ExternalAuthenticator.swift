//
//  ExternalAuthenticator.swift
//  MPOLKit
//
//  Created by Herli Halim on 10/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import SafariServices
import PromiseKit

public final class ExternalAuthenticator {

    private static var safariViewController: SFSafariViewController? = nil
    private static var authenticationProvider: AuthenticationProvider? = nil
    private static var pendingPromiseResult: Promise<[String: String]>.PendingTuple? = nil

    /// Whether the authentication will be facilitated through SFSafariViewController.
    /// Defaults to `true`. If this value is `false`, Safari will be used.
    public static var useSafariViewController: Bool = true

    public static func authenticate(_ authenticationProvider: AuthenticationProvider) -> Promise<[String: String]> {
        self.authenticationProvider = authenticationProvider
        presentAuthentication(authenticationProvider.authorizationURL)

        let pendingTuple: Promise<[String: String]>.PendingTuple = Promise.pending()
        self.pendingPromiseResult = pendingTuple

        return pendingTuple.promise
    }


    public static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        if let safariViewController = safariViewController {
            safariViewController.dismiss(animated: true, completion: nil)
            self.safariViewController = nil
        }

        // Not what we want, return false so other could handle it.s
        guard let authenticationProvider = authenticationProvider, url.scheme == authenticationProvider.urlScheme else {
            return false
        }

        guard let pending = pendingPromiseResult else {
            return false
        }

        let result = authenticationProvider.authenticationLinkResult(url)
        result.then {
            pending.fulfill($0)
        }.catch {
            pending.reject($0)
        }

        self.authenticationProvider = nil
        self.pendingPromiseResult = nil

        return true
    }

    // MARK: - Private Utilities

    private static func presentAuthentication(_ url: URL) {

        if useSafariViewController {
            let safariViewController = SFSafariViewController(url: url)
            var topController = UIApplication.shared.keyWindow?.rootViewController
            while let vc = topController?.presentedViewController {
                topController = vc
            }
            topController?.present(safariViewController, animated: true, completion: nil)
            self.safariViewController = safariViewController
        } else {
            UIApplication.shared.open(url, options: [ UIApplicationOpenURLOptionUniversalLinksOnly : true ], completionHandler: nil)
        }

    }

}
