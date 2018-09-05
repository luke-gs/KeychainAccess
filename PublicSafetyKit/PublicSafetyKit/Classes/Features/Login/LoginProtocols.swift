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

extension LoginViewControllerDelegate {
    public func loginViewControllerDidAppear(_ controller: LoginViewController) {

    }
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

public enum BiometricPromptEvent {
    case loginViewControllerDidAppear
    case applicationDidBecomeActive
}

/// LoginViewController delegate used with The basic credentials and biometrics
public protocol BiometricDelegate: CredentialsDelegate {

    /// Text to use for logging using biometric.
    ///
    /// - Parameter loginViewController: The login view controller.
    /// - Returns: The appropriate prompt to login using biometric.
    func biometricAuthenticationPrompt(for loginViewController: LoginViewController) -> String

    /// Called to ask the delegate whether biometric should still be enabled.
    ///
    /// - Parameters:
    ///   - loginViewController: The login view controller.
    ///   - canUseBiometricWithDomainPolicyState: The current domain policy state data blob from LAContext.
    /// - Returns: A Bool to indicate whether biometric should still be enabled.
    func loginViewController(_ loginViewController: LoginViewController, canUseBiometricWithPolicyDomainState policyDomainState: Data?) -> Bool

    /// Called on the specified event to ask whether the biometric prompt should be presented without user interaction.
    ///
    /// - Parameters:
    ///   - loginViewController: The login view controller.
    ///   - event: The event that cause the need to prompt.
    /// - Returns: A Bool to indicate whether the prompt should appear or not.
    func loginViewController(_ loginViewController: LoginViewController, shouldPromptForEvent event: BiometricPromptEvent) -> Bool

    /// Triggers when The login button is pressed
    ///
    /// - Parameters:
    ///   - controller: The login view controller
    ///   - context: The local authentication context
    func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext)
}

extension BiometricDelegate {

    public func loginViewController(_ loginViewController: LoginViewController, canUseBiometricWithPolicyDomainState domainPolicyState: Data?) -> Bool {
        return true
    }

    public func loginViewController(_ loginViewController: LoginViewController, shouldPromptForEvent event: BiometricPromptEvent) -> Bool {
        return false
    }
}

/// LoginViewController delegate used with external authentication
public protocol ExternalAuthDelegate: LoginViewControllerDelegate {

    /// Triggers when The login button is pressed
    ///
    /// - Parameters:
    ///   - controller: The login view controller
    func loginViewControllerDidCommenceExternalAuth(_ controller: LoginViewController)
}

