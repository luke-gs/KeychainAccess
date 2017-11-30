//
//  PersonEditViewController.swift
//  ClientKit
//
//  Created by KGWH78 on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class PersonEditViewController: FormBuilderViewController {

    // MARK: - Reference

    public let initialPerson: Person?

    // MARK: - Storage

    private let finalPerson = Person()
    private let finalDescription = PersonDescription()

    private let mobile: Contact = {
        let contact = Contact()
        contact.type = .mobile
        return contact
    }()

    private let home: Contact = {
        let contact = Contact()
        contact.type = .phone
        return contact
    }()

    private let work: Contact = {
        let contact = Contact()
        contact.type = .phone
        return contact
    }()

    private let email: Contact = {
        let contact = Contact()
        contact.type = .email
        return contact
    }()

    private let numberFormatter = NumberFormatter()

    // MARK: - Initializer

    public init(initialPerson: Person? = nil) {
        self.initialPerson = initialPerson
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtonTapped(_:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func construct(builder: FormBuilder) {

        builder.title = "Person"

        builder += HeaderFormItem(text: "DETAILS")

        builder += TextFieldFormItem()
            .title("First Name")
            .text(initialPerson?.givenName)
            .onValueChanged({ self.finalPerson.givenName = $0 })
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Middle Name")
            .text(initialPerson?.middleNames)
            .onValueChanged({ self.finalPerson.middleNames = $0 })
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Family Name")
            .text(initialPerson?.surname)
            .onValueChanged({ self.finalPerson.surname = $0 })
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Other Given Names")
            .width(.column(4))

        let selectedGender = initialPerson?.gender != nil ? [initialPerson!.gender!] : nil

        builder += DropDownFormItem()
            .title("Gender")
            .options(Person.Gender.allCases)
            .selectedValue(selectedGender)
            .onValueChanged({ self.finalPerson.gender = $0?.first })
            .required()
            .width(.column(2))

        builder += DateFormItem()
            .title("Date Of Birth")
            .dateFormatter(.formDate)
            .selectedValue(initialPerson?.dateOfBirth)
            .onValueChanged({ self.finalPerson.dateOfBirth = $0 })
            .required()
            .width(.column(2))

        builder += HeaderFormItem(text: "DESCRIPTION")

        builder += TextFieldFormItem()
            .title("Height (cm)")
            .onValueChanged({
                if let text = $0, let value = self.numberFormatter.number(from: text)?.intValue {
                    self.finalDescription.height = value
                } else {
                    self.finalDescription.height = nil
                }
            })
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Height can only be number.")
            .strictValidate(CountSpecification.max(3), message: "Maximum number of characters reached.")
            .width(.column(3))

        builder += TextFieldFormItem()
            .title("Weight (Kg)")
            .onValueChanged({ self.finalDescription.weight = $0 })
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Weight can only be number.")
            .strictValidate(CountSpecification.max(3), message: "Maximum number of characters reached.")
            .width(.column(3))

        builder += DropDownFormItem()
            .title("Build")
            .options(["Light", "Medium", "Heavy"])
            .onValueChanged({ self.finalDescription.build = $0?.first })
            .width(.column(3))

        builder += DropDownFormItem()
            .title("Race")
            .options(["Asian", "African", "Causcasian", "European", "Aboriginal"])
            .onValueChanged({ self.finalDescription.race = $0?.first })
            .width(.column(3))

        builder += DropDownFormItem()
            .title("Hair Colour")
            .options(["Black", "Blond", "Light Brown", "Dark Brown", "Red", "Gray", "White"])
            .onValueChanged({ self.finalDescription.hairColour = $0?.first })
            .width(.column(3))

        builder += DropDownFormItem()
            .title("Eye Colour")
            .options(["Black", "Brown", "Blue", "Green", "Gray", "Amber", "Hazel"])
            .onValueChanged({ self.finalDescription.eyeColour = $0?.first })
            .width(.column(3))

        builder += HeaderFormItem(text: "ADDRESSES")

        builder += TextFieldFormItem()
            .title("Residential Address")
            .required()
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Work Address")
            .width(.column(2))

        builder += HeaderFormItem(text: "CONTACT DETAILS")

        builder += TextFieldFormItem()
            .title("Mobile Number")
            .onValueChanged({ self.mobile.value = $0 })
            .required()
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Home Number")
            .onValueChanged({ self.home.value = $0 })
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Work Number")
            .onValueChanged({ self.work.value = $0 })
            .width(.column(2))

        builder += TextFieldFormItem()
            .title("Email Address")
            .onValueChanged({ self.email.value = $0 })
            .width(.column(2))
            .softValidate(EmailSpecification(), message: "Invalid email address.")

    }

    // MARK: - Private

    @objc private func cancelButtonTapped(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func submitButtonTapped(_ item: UIBarButtonItem) {
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            if var descriptions = finalPerson.descriptions {
                descriptions.append(finalDescription)
                finalPerson.descriptions = descriptions
            } else {
                finalPerson.descriptions = [finalDescription]
            }

            if var contacts = finalPerson.contacts {
                contacts += [mobile, home, work, email]
                finalPerson.contacts = contacts
            } else {
                finalPerson.contacts = [mobile, home, work, email]
            }

            UserSession.current.recentlyActioned.add(finalPerson)
            self.dismiss(animated: true, completion: nil)

            break
        }
    }

}
