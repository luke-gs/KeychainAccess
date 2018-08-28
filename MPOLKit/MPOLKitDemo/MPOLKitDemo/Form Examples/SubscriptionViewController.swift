//
//  SubscriptionViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 6/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit


class SubscriptionViewController: FormBuilderViewController {

    override init() {
        super.init()

        let fixerUpper = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixerUpper.width = 20.0

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done)),
            fixerUpper,
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        ]
    }

    override func construct(builder: FormBuilder) {

        builder += HeaderFormItem(text: "WELCOME", style: .plain)

        builder += TextFieldFormItem()
            .title("Username")
            .required()
            .width(.column(1))
            .strictValidate(CharacterSetSpecification.letters & CountSpecification.max(100), message: "Invalid")

        let password = TextFieldFormItem().title("Password")
            .required()
            .width(.column(2))
            .secureTextEntry(true)
            .strictValidate(CountSpecification.max(100), message: "Max 100 characters")
            .submitValidate(CountSpecification.min(5), message: "Min 5 characters")

        let confirmPassword = TextFieldFormItem().title("Confirm Password")
            .required()
            .width(.column(2))
            .secureTextEntry(true)

        password.onValueChanged { [unowned confirmPassword] _ in
            confirmPassword.reloadLiveValidationState()
        }

        confirmPassword.softValidate(PredicateSpecification() { [unowned password] (text: String) -> Bool in
            return password.text?.sizing().string == text
        }, message: "Password must be matching")

        builder += [password, confirmPassword]

        builder += TextFieldFormItem().title("Email")
            .required()
            .width(.column(1))
            .keyboardType(.emailAddress)
            .softValidate(EmailSpecification(), message: "Invalid email")

        builder += TextViewFormItem()
            .title("Notes")
            .height(.fixed(100.0))

        builder += OptionGroupFormItem(optionStyle: .checkbox, options: [
                "I agreee to the terms and conditions",
                "Subscribe to newsletters"
            ])
            .title("Agrees to terms and condition")
            .required()
    }

    @objc private func done() {
        builder.validateAndUpdateUI()
    }

    @objc private func reset() {
        reloadForm()
    }

}
