//
//  SignViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 21/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class SignupViewController: FormViewController {

    var details = SignupDetails()

    override init() {
        super.init()

        let fixerUpper = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixerUpper.width = 20.0

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitFormTapped)),
            fixerUpper,
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetFormTapped))
        ]
    }

    override func construct(builder: FormBuilder) {

        builder.title = "Signup"

        builder += HeaderFormItem(text: "PERSONAL DETAILS", style: .plain)

        builder += TextFieldFormItem(title: "Firstname", text: nil, placeholder: "Enter firstname")
            .width(.column(3))
            .required("Firstname is required.")
            .strictValidate(CharacterSetSpecification.alphanumerics, message: "Firstname must be alphanumerics")
            .softValidate(CountSpecification.between(3, 20), message: "Firstname must be between 3 and 20 characters")
            .onValueChanged { [unowned self] in
                self.details.firstname = $0
            }


        builder += TextFieldFormItem(title: "Middle name", text: nil, placeholder: "Enter middle name")
            .width(.column(3))
            .softValidate(CountSpecification.between(3, 20), message: "Middle name must be between 3 and 20 characters")
            .strictValidate(CharacterSetSpecification.alphanumerics, message: "Middle name must be alphanumerics")
            .onValueChanged { [unowned self] in
                self.details.middleName = $0
            }

        builder += TextFieldFormItem(title: "Surname", text: nil, placeholder: "Enter surname")
            .width(.column(3))
            .required()
            .softValidate(CountSpecification.between(3, 20), message: "Surname must be between 3 and 20 characters")
            .strictValidate(CharacterSetSpecification.alphanumerics, message: "Surname must be alphanumerics")
            .onValueChanged { [unowned self] in
                self.details.surname = $0
            }

        builder += PickerFormItem(pickerAction: DateAction(title: "Date of birth", mode: .date))
            .width(.column(2))
            .required()
            .onValueChanged { [unowned self] in
                self.details.dateOfBirth = $0
            }

        builder += PickerFormItem(pickerAction: PickerAction(title: "Gender", options: ["Male", "Female", "Unknown"]))
            .width(.column(2))
            .required()
            .onValueChanged { [unowned self] in
                self.details.gender = $0?.first
            }

        builder += TextFieldFormItem(title: "Email", text: nil, placeholder: "Enter email")
            .width(.column(1))
            .softValidate(EmailSpecification(), message: "Invalid email")
            .onValueChanged { [unowned self] in
                self.details.email = $0
            }

        builder += PickerFormItem(pickerAction: NumberRangeAction(title: "Age range", range: 1...30))
            .width(.column(1))
            .onValueChanged { [unowned self] in
                self.details.ageRange = $0
            }


        builder += HeaderFormItem(text: "ADDRESS", style: .plain)

        builder += TextFieldFormItem(title: "Address Line 1", text: nil, placeholder: "Address line 1")
            .width(.column(1))
            .strictValidate(CountSpecification.max(100), message: "Maximum 100 characters.")
            .onValueChanged { [unowned self] in
                self.details.addressLine1 = $0
            }

        builder += TextFieldFormItem(title: "Address Line 2", text: nil, placeholder: "Address line 2")
            .width(.column(1))
            .strictValidate(CountSpecification.max(100), message: "Maximum 100 characters.")
            .onValueChanged { [unowned self] in
                self.details.addressLine2 = $0
            }

        builder += TextFieldFormItem(title: "State", text: nil, placeholder: "State")
            .width(.column(2))
            .submitValidate(CountSpecification.exactly(3), message: "State must be 3 characters")
            .strictValidate(CountSpecification.max(3), message: "State must be 3 characters")
            .onValueChanged { [unowned self] in
                self.details.state = $0
            }

        builder += TextFieldFormItem(title: "Postcode", text: nil, placeholder: "Postcode")
            .width(.column(2))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Postcode must be 4 digits")
            .softValidate(CountSpecification.exactly(4), message: "Postcode must be 4 digits")
            .onValueChanged { [unowned self] in
                self.details.postcode = $0
            }


        builder += HeaderFormItem(text: "MISC", style: .plain)

        builder += TextViewFormItem(title: "Description", text: nil, placeholder: "Tell us about yourself.")
            .height(.fixed(140.0))
            .strictValidate(CountSpecification.max(20), message: "Exceed 20 characters limit")
            .softValidate(CountSpecification.min(1), message: "This is required")
            .onValueChanged { [unowned self] in
                self.details.moreDescription = $0
            }
            .required()

        builder += TextFieldFormItem(title: "Motto", text: nil, placeholder: "Enter your motto")
            .width(.column(1))
            .onValueChanged { [unowned self] in
                self.details.motto = $0
            }

        builder += PickerFormItem(pickerAction: PickerAction(title: "Interests", options: ["Games", "Sports", "Manga", "Anime", "People", "Travel"], selectedIndexes: nil, allowMultipleSelection: true))
            .width(.column(1))
            .onValueChanged { [unowned self] in
                self.details.interests = $0
            }

        builder += HeaderFormItem(text: "PRIZES", style: .plain)
        builder += OptionGroupFormItem(optionStyle: .radio, options: ["iPhone X", "iPad Pro", "Apple Watch"])
            .title("Please select a prize")
            .required()
            .onValueChanged { [unowned self] in
                if let index = $0.first {
                    self.details.prize = ["iPhone X", "iPad Pro", "Apple Watch"][index]
                } else {
                    self.details.prize = nil
                }
            }
        builder += TextFieldFormItem().title("Other")
            .placeholder("Enter Other")
            .width(.column(1))
            .required()

        builder += HeaderFormItem(text: "AGREEMENTS", style: .plain)
        builder += OptionGroupFormItem(optionStyle: .checkbox, options: [
                "I agreed to the terms and conditions.",
                "I accepted the the privacy policies.",
                "I would like to sign up to the newsletter."
            ])
            .onValueChanged { [unowned self] in
                self.details.termsConditionAccepted = $0.contains(0)
                self.details.privacyPoliciesAccepted = $0.contains(1)
                self.details.signupToNewsletter = $0.contains(2)
            }

    }

    @objc private func resetFormTapped() {
        reloadForm()
    }

    @objc private func submitFormTapped() {
        let result = builder.validate()

        switch result {
        case .invalid(let item, let message):
            builder.validateAndUpdateUI()

            let alertController = UIAlertController(title: "Invalid", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Show me", style: .default, handler: { _ in
                let data = DebugDumpVisitor.dump(items: self.builder.formItems)
                self.present(UINavigationController(rootViewController: DebugViewController(json: data)),
                             animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.gotoItem(item)
            }))
            present(alertController, animated: true, completion: nil)
        case .valid:
            let alertController = UIAlertController(title: "Form is valid", message: "Thank you.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

}

import Wrap

class SignupDetails {

    var surname: String?

    var middleName: String?

    var firstname: String?

    var dateOfBirth: Date?

    var gender: String?

    var email: String?

    var ageRange: CountableClosedRange<Int>?

    var addressLine1: String?

    var addressLine2: String?

    var state: String?

    var postcode: String?

    var moreDescription: String?

    var motto: String?

    var interests: [String]?

    var prize: String?

    var termsConditionAccepted: Bool = false

    var privacyPoliciesAccepted: Bool = false

    var signupToNewsletter: Bool = false

}
