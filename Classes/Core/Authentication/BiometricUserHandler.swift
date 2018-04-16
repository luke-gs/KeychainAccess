//
//  BiometricUser.swift
//  ClientKit
//
//  Created by Herli Halim on 11/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import KeychainAccess
import PromiseKit
import LocalAuthentication

public enum UseBiometric: String {
    case unknown
    case asked
    case agreed
}

public struct BiometricUserHandler {

    public let username: String
    public let keychain: Keychain

    private let _passwordKey: String
    private let _queue = DispatchQueue(label: "au.com.gridstone.BiometricUserHandlerQueue")

    public init(username: String, keychain: Keychain) {
        self.username = username
        self.keychain = keychain

        // Prefix the key with random String.
        _passwordKey = BiometricUserHandler.prefixedKey(username)
    }


    /// Save password to keychain. The password will only be accessible if the user could provide credentials using the LocalAuthentication.
    /// If LAContext is provided, it'll re-use the context otherwise, this will present the Biometric authentication prompt.
    ///
    /// - Parameters:
    ///   - password: The password to be saved.
    ///   - context: The context to be re-used. The context won't be used to present prompt, rather it'll just be used as is to skip authentication if already provided.
    ///   - prompt: The text prompt. Will only be used if no authentication has been provided.
    /// - Returns: Promise to indicate whether saving is successful or failed.
    public func setPassword(_ password: String?, context: LAContext? = nil, prompt: String? = nil) -> Promise<Void> {
        let (promise, seal) = Promise<Void>.pending()
        let current = keychain(keychain, context: context, prompt: prompt)
        let key = _passwordKey

        _queue.async {
            do {
                if let password = password {
                    try current.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDCurrentSet)
                        .set(password, key: key)
                    seal.fulfill(())
                } else {
                    // Password can be removed without context.
                    try current.remove(key)
                    seal.fulfill(())
                }
            } catch {
                seal.reject(error)
            }
        }

        return promise
    }


    /// Retrieve password from keychain. The password will only be accessible if the user could provide credentials using the LocalAuthentication.
    ///
    /// - Parameters:
    ///   - context: The context to be re-used. The context won't be used to present prompt, rather it'll just be used as is to skip authentication if already provided.
    ///   - prompt: The text prompt. Will only be used if no authentication has been provided.
    /// - Returns: Promise with the value of password if exist. Note that the value is Optional, so nil will be returned if there's no password.
    ///            The error will only be thrown when it's due to failure from Keychain API.
    public func password(context: LAContext? = nil, prompt: String? = nil) -> Promise<String?> {
        let (promise, seal) = Promise<String?>.pending()
        let current = keychain(keychain, context: context, prompt: prompt)
        let key = _passwordKey

        _queue.async {
            do {
                let password = try current.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDCurrentSet).get(key)
                seal.fulfill(password)
            } catch {
                seal.reject(error)
            }
        }

        return promise
    }

    public var useBiometric: UseBiometric {
        get {

            if let user = UserSession.loadUser(username: username) {
                if let rawValue = user.appSettingValue(forKey: .useBiometric) as? String,
                    let value = UseBiometric(rawValue: rawValue) {
                    return value
                }
            }

            return .unknown
        }
        set {
            if let user = UserSession.loadUser(username: username) {
                user.setAppSettingValue(newValue.rawValue as AnyObject, forKey: .useBiometric)
                UserSession.save(user: user)
            }

        }

    }

    /// Become the last `logged in` Biometric User.
    public func becomeCurrentUser() {
        try? keychain.set(username, key: BiometricUserHandler.prefixedKey("currentUser"))
    }

    /// Retrieve current `logged in` Biometric User from the provided keychain.
    ///
    /// - Parameter keychain: The keychain where the user might be stored.
    /// - Returns: The BiometricUserHandler that's last stored from `becomeCurrentUser()`
    public static func currentUser(in keychain: Keychain) -> BiometricUserHandler? {
        let key = prefixedKey("currentUser")
        guard let username = try? keychain.get(key), let currentUsername = username else {
            return nil
        }
        return BiometricUserHandler(username: currentUsername, keychain: keychain)
    }

    // MARK: - Private, not for your viewing pleasure.

    private func keychain(_ keychain: Keychain, context: LAContext?, prompt: String? = nil) -> Keychain {
        var new = keychain
        if let context = context {
            new = new.authenticationContext(context)
        }
        if let prompt = prompt {
            new = new.authenticationPrompt(prompt)
        }
        return new
    }

    static private let prefix = "bm_dont_touch"

    static fileprivate func prefixedKey(_ key: String) -> String {
        return "\(BiometricUserHandler.prefix)-\(key)"
    }

}

extension AppSettingKey {
    public static let useBiometric = AppSettingKey(rawValue: BiometricUserHandler.prefixedKey("useBiometric"))
}
