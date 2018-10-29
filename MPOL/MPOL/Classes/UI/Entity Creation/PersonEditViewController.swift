//
//  PersonEditViewController.swift
//  MPOL
//
//  Created by KGWH78 on 20/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// Displays create person screen
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

    private struct DetailCreationConstant {
        static let ContactScreenSize = CGSize(width: 512, height: 256)
        static let AliasScreenSize = CGSize(width: 512, height: 328)
        static let AddressScreenSize = CGSize(width: 512, height: 376)
    }

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

        builder += LargeTextHeaderFormItem(text: "General").separatorColor(.clear)

        builder += TextFieldFormItem()
            .title("First Name")
            .text(initialPerson?.givenName)
            .onValueChanged { self.finalPerson.givenName = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Middle Name/s")
            .text(initialPerson?.middleNames)
            .onValueChanged { self.finalPerson.middleNames = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Last Name")
            .text(initialPerson?.familyName)
            .onValueChanged { self.finalPerson.familyName = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Identification Number")
            .width(.column(4))

        let selectedGender = initialPerson?.gender != nil ? [initialPerson!.gender!] : nil

        builder += DateFormItem()
            .title("Date Of Birth")
            .dateFormatter(.preferredDateStyle)
            .selectedValue(initialPerson?.dateOfBirth)
            .onValueChanged { self.finalPerson.dateOfBirth = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Place of Birth")
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Ethnicity")
            .width(.column(4))

        // TODO: Use Manifest
        builder += DropDownFormItem()
            .title("Gender")
            .options(Person.Gender.allCases)
            .selectedValue(selectedGender)
            .onValueChanged { self.finalPerson.gender = $0?.first }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: "Physical Description").separatorColor(.clear)

        builder += TextFieldFormItem()
            .title("Height (cm)")
            .placeholder("0 cm")
            .onValueChanged {
                if let text = $0, let value = self.numberFormatter.number(from: text)?.intValue {
                    self.finalDescription.height = value
                } else {
                    self.finalDescription.height = nil
                }
            }
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Height can only be number.")
            .strictValidate(CountSpecification.max(3), message: "Maximum number of characters reached.")
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Weight (kg)")
            .placeholder("0 kg")
            .onValueChanged { self.finalDescription.weight = $0 }
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Weight can only be number.")
            .strictValidate(CountSpecification.max(3), message: "Maximum number of characters reached.")
            .width(.column(4))

        if let items = Manifest.shared.entries(for: .personBuild)?.rawValues() {
            builder += DropDownFormItem()
                .title("Build")
                .options(items)
                .onValueChanged { self.finalDescription.build = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personRace)?.rawValues() {
            builder += DropDownFormItem()
                .title("Race")
                .options(items)
                .onValueChanged { self.finalDescription.race = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personEyeColour)?.rawValues() {
            builder += DropDownFormItem()
                .title("Eye Colour")
                .options(items)
                .onValueChanged { self.finalDescription.eyeColour = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personHairColour)?.rawValues() {
            builder += DropDownFormItem()
                .title("Hair Colour")
                .options(items)
                .onValueChanged { self.finalDescription.hairColour = $0?.first }
                .width(.column(4))
        }

        builder += TextFieldFormItem()
            .title("Remarks")
            .width(.column(2))

//        builder += HeaderFormItem(text: "ADDRESSES")
//
//        builder += TextFieldFormItem()
//            .title("Residential Address")
//            .required()
//            .width(.column(2))
//
//        builder += TextFieldFormItem()
//            .title("Work Address")
//            .width(.column(2))
//
//        builder += HeaderFormItem(text: "CONTACT DETAILS")
//
//        builder += TextFieldFormItem()
//            .title("Mobile Number")
//            .onValueChanged { self.mobile.value = $0 }
//            .required()
//            .width(.column(2))
//
//        builder += TextFieldFormItem()
//            .title("Home Number")
//            .onValueChanged { self.home.value = $0 }
//            .width(.column(2))
//
//        builder += TextFieldFormItem()
//            .title("Work Number")
//            .onValueChanged { self.work.value = $0 }
//            .width(.column(2))
//
//        builder += TextFieldFormItem()
//            .title("Email Address")
//            .onValueChanged { self.email.value = $0 }
//            .width(.column(2))
//            .softValidate(EmailSpecification(), message: "Invalid email address.")

        builder += LargeTextHeaderFormItem(text: "Contact Details")
            .actionButton(title: "Add", handler: { [unowned self] (button) in
                self.presentDetailViewController(type: .Contact(.Empty))
            })

        builder += LargeTextHeaderFormItem(text: "Aliases")
            .actionButton(title: "Add", handler: { (button) in
                self.presentDetailViewController(type: .Alias(.Empty))
            })

        builder += LargeTextHeaderFormItem(text: "Addresses")
            .actionButton(title: "Add", handler: { (button) in
                self.presentDetailViewController(type: .Address)
            })
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

            //TODO: Add final person to user preferences

            self.dismiss(animated: true, completion: nil)
        }
    }

    private func presentDetailViewController(type: DetailCreationType) {
        let detailViewController = DetailCreationViewController(viewModel: DetailCreationViewModel(type: type))
        let container = ModalNavigationController(rootViewController: detailViewController)
        var screenSize: CGSize
        switch type {
        case .Contact:
            screenSize = DetailCreationConstant.ContactScreenSize
        case .Alias:
            screenSize = DetailCreationConstant.AliasScreenSize
        case .Address:
            screenSize = DetailCreationConstant.AddressScreenSize
        }
        // TODO: change to use Presenter
        self.present(container, size: screenSize)
    }

}
