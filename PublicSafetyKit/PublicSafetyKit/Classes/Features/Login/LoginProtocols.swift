//
//  LoginProtocols.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import LocalAuthentication

/// Credential used in The `LoginViewController` to define and verify The various
/// properties required to login
public protocol LoginCredential: class {

    /// The name of The credential
    var name: String { get }

    /// The value of The credential
    /// Automatically gets populated by The text field
    var value: String? { get set }

    /// Whether this field is required to enable The login button
    var isRequired: Bool { get }

    /// Implement your own logic to determine if The current value
    /// makes The credential valid
    ///
    /// eg. > 6 characters
    var isValid: Bool { get }

    /// The `LabeledTextField` for this credential.
    /// Customise to your hearts content
    var inputField: LabeledTextField { get }
}

/// The types of login modes PS Core supports
///
/// - credentials: basic credentials
/// - credentialsWithBiometric: basic credentials with biometrics
/// - externalAuth: external authentication
public enum LoginMode {
    case credentials(delegate: CredentialsDelegate?)
    case credentialsWithBiometric(delegate: BiometricDelegate?)
    case externalAuth(delegate: ExternalAuthDelegate?)
}

/// Login View Controller delegate
public protocol LoginViewControllerDelegate {

    /// Triggers when The login view controller appears
    ///
    /// - Parameter controller: The login view controller
    func loginViewControllerDidAppear(_ controller: LoginViewController)
}

/// LoginViewController delegate used with The basic credentials `LoginMode`
public protocol CredentialsDelegate: LoginViewControllerDelegate {

    /// Triggers when The login button is pressed
    ///
    /// - Parameters:
    ///   - controller: The login viewController
    ///   - didFinishWithCredentials: The array of credentials, do what you will with them
    func loginViewController(_ controller: LoginViewController, didFinishWithCredentials: [LoginCredential])
}

/// LoginViewController delegate used with The basic credentials and biometrics
public protocol BiometricDelegate: CredentialsDelegate {

    /// Triggers when The login button is pressed
    ///
    /// - Parameters:
    ///   - controller: The login view controller
    ///   - context: The local authentication context
    func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext)
}

/// LoginViewController delegate used with external authentication
public protocol ExternalAuthDelegate: LoginViewControllerDelegate {

    /// Triggers when The login button is pressed
    ///
    /// - Parameters:
    ///   - controller: The login view controller
    func loginViewControllerDidCommenceExternalAuth(_ controller: LoginViewController)
}

