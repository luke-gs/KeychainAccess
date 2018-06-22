//
//  LoginProtocols.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import LocalAuthentication

public protocol LoginCredential: class {
    var name: String { get }
    var value: String? { get set }
    var isRequired: Bool { get }
    var isValid: Bool { get }
    var inputField: LabeledTextField { get }
}

public enum LoginMode {
    case credentials(delegate: CredentialsDelegate?)
    case credentialsWithBiometric(delegate: BiometricDelegate?)
    case externalAuth(delegate: ExternalAuthDelegate?)
}

public protocol LoginViewControllerDelegate {
    func loginViewControllerDidAppear(_ controller: LoginViewController)
}

public protocol CredentialsDelegate: LoginViewControllerDelegate {
    func loginViewController(_ controller: LoginViewController, didFinishWithCredentials: [LoginCredential])
}

public protocol BiometricDelegate: CredentialsDelegate {
    func loginViewControllerDidAuthenticateWithBiometric(_ controller: LoginViewController, context: LAContext)
}

public protocol ExternalAuthDelegate: LoginViewControllerDelegate {
    func loginViewControllerDidCommenceExternalAuth(_ controller: LoginViewController)
}

