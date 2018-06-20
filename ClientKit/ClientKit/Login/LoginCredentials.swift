//
//  LoginCredentials.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public struct UsernameCredential: LoginCredential {
    public var name: String = "Username"
    public var value: String?
    public var isRequired: Bool = true
    public var isValid: Bool {
        guard let value = value else { return false }
        return value.count > 1
    }

    public var inputField: LabeledTextField {
        let field = LabeledTextField()

        field.label.text = NSLocalizedString("Identification Number", comment: "")
        field.label.textColor = .white

        let textField = field.textField
        textField.accessibilityLabel = NSLocalizedString("Username Field", comment: "Accessibility")
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.textColor = .white
        textField.autocorrectionType = .no

        NSLayoutConstraint.activate([field.heightAnchor.constraint(equalToConstant: 60)])

        return field
    }
}

public struct PasswordCredential: LoginCredential {
    public var name: String = "Password"
    public var value: String?
    public var isRequired: Bool = true
    public var isValid: Bool {
        guard let value = value else { return false }
        return value.count > 1
    }

    public var inputField: LabeledTextField {
        let field = LabeledTextField()

        field.label.textColor = .white
        field.label.text = NSLocalizedString("Password", comment: "")

        let textField = field.textField
        textField.accessibilityLabel = NSLocalizedString("Password Field", comment: "Accessibility")
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = true
        textField.textColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        NSLayoutConstraint.activate([field.heightAnchor.constraint(equalToConstant: 60)])

        return field
    }
}
