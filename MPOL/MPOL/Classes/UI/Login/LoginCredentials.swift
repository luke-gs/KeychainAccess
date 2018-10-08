//
//  LoginCredentials.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class UsernameCredential: LoginCredential {
    public var name: String = "Username"
    public var value: String?
    public var isRequired: Bool = true
    public var inputField: LabeledTextField
    public var isValid: Bool {
        guard let value = value else { return false }
        return value.count > 1
    }

    public init(username: String?) {
        inputField = LabeledTextField()

        inputField.label.text = NSLocalizedString("Identification Number", comment: "")
        inputField.label.textColor = .white

        let textField = inputField.textField
        textField.accessibilityLabel = NSLocalizedString("Username Field", comment: "Accessibility")
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.autocorrectionType = .no

        value = username
        #if DEBUG
        value = "gridstone"
        #endif
    }
}

public class PasswordCredential: LoginCredential {
    public var name: String = "Password"
    public var value: String?
    public var isRequired: Bool = true
    public var inputField: LabeledTextField
    public var isValid: Bool {
        guard let value = value else { return false }
        return value.count > 1
    }

    public init() {
        inputField = LabeledTextField()

        inputField.label.textColor = .white
        inputField.label.text = NSLocalizedString("Password", comment: "")

        let textField = inputField.textField
        textField.accessibilityLabel = NSLocalizedString("Password Field", comment: "Accessibility")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = true
        textField.textColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        #if DEBUG
        value = "mock"
        #endif
    }
}
