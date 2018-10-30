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
            .text(finalPerson.givenName ?? initialPerson?.givenName)
            .onValueChanged { self.finalPerson.givenName = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Middle Name/s")
            .text(finalPerson.middleNames ?? initialPerson?.middleNames)
            .onValueChanged { self.finalPerson.middleNames = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Last Name")
            .text(finalPerson.familyName ?? initialPerson?.familyName)
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
            .selectedValue(finalPerson.dateOfBirth ?? initialPerson?.dateOfBirth)
            .onValueChanged { self.finalPerson.dateOfBirth = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Place of Birth")
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Ethnicity")
            .width(.column(4))

        builder += DropDownFormItem()
            .title("Gender")
            .options(Person.Gender.allCases)
            .selectedValue(selectedGender)
            .onValueChanged { self.finalPerson.gender = $0?.first }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: "Physical Description").separatorColor(.clear)

        builder += TextFieldFormItem()
            .title("Height (cm)")
            .text(finalDescription.height != nil ? String(finalDescription.height!) : nil)
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
            .text(finalDescription.weight != nil ? String(finalDescription.weight!) : nil)
            .placeholder("0 kg")
            .onValueChanged { self.finalDescription.weight = $0 }
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Weight can only be number.")
            .strictValidate(CountSpecification.max(3), message: "Maximum number of characters reached.")
            .width(.column(4))

        if let items = Manifest.shared.entries(for: .personBuild)?.rawValues() {
            builder += DropDownFormItem()
                .title("Build")
                .options(items)
                .selectedValue(finalDescription.build != nil ? [finalDescription.build!] : nil)
                .onValueChanged { self.finalDescription.build = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personRace)?.rawValues() {
            builder += DropDownFormItem()
                .title("Race")
                .options(items)
                .selectedValue(finalDescription.race != nil ? [finalDescription.race!] : nil)
                .onValueChanged { self.finalDescription.race = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personEyeColour)?.rawValues() {
            builder += DropDownFormItem()
                .title("Eye Colour")
                .options(items)
                .selectedValue(finalDescription.eyeColour != nil ? [finalDescription.eyeColour!] : nil)
                .onValueChanged { self.finalDescription.eyeColour = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personHairColour)?.rawValues() {
            builder += DropDownFormItem()
                .title("Hair Colour")
                .options(items)
                .selectedValue(finalDescription.hairColour != nil ? [finalDescription.hairColour!] : nil)
                .onValueChanged { self.finalDescription.hairColour = $0?.first }
                .width(.column(4))
        }

        builder += TextFieldFormItem()
            .title("Remarks")
            .width(.column(2))

        builder += LargeTextHeaderFormItem(text: "Contact Details")
            .actionButton(title: "Add", handler: { [unowned self] _ in
                self.present(EntityScreen.createEntityDetail(type: .contact(.empty),
                                                             delegate: self))
            })

        if let contacts = finalPerson.contacts {
            for (index, contact) in contacts.enumerated() {
                builder += TextFieldFormItem()
                    .title(contact.type?.rawValue)
                    .text(contact.value)
                    .width(.column(1))
                    .onValueChanged { [unowned self] value in
                        self.finalPerson.contacts?[index].value = value
                }
            }
        }

        builder += LargeTextHeaderFormItem(text: "Aliases")
            .actionButton(title: "Add", handler: { _ in
                self.present(EntityScreen.createEntityDetail(type: .alias(.empty),
                                                             delegate: self))
            })

        if let aliases = finalPerson.aliases {
            for (index, alias) in aliases.enumerated() {
                if let nickname = alias.nickname {
                    builder += TextFieldFormItem()
                        .title(alias.type)
                        .text(nickname)
                        .width(.column(1))
                        .onValueChanged { [unowned self] value in
                            self.finalPerson.aliases?[index].nickname = value
                    }
                } else {
                    // TODO: how should the creative look when displaying maiden name etc
                    builder += TextFieldFormItem()
                        .title(alias.type)
                        .text((alias.lastName ?? "") + (alias.middleNames ?? "") + (alias.firstName ?? ""))
                        .width(.column(1))
                        .onValueChanged { [unowned self] value in
                            // TODO: add handling
                    }
                }
            }
        }

        builder += LargeTextHeaderFormItem(text: "Addresses")
            .actionButton(title: "Add", handler: { _ in
                self.present(EntityScreen.createEntityDetail(type: .address(.empty),
                                                             delegate: self))
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

            // TODO: Add final person to user preferences

            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PersonEditViewController: DetailCreationDelegate {

    public func onCompleteContact(contact: Contact) {
        if finalPerson.contacts != nil {
            finalPerson.contacts!.append(contact)
        } else {
            finalPerson.contacts = [contact]
        }
        reloadForm()
    }

    public func onCompleteAlias(alias: PersonAlias) {
        if finalPerson.aliases != nil {
            finalPerson.aliases!.append(alias)
        } else {
            finalPerson.aliases = [alias]
        }
        reloadForm()
    }

    public func onCompleteAddress(address: Address) {
        // TODO
        reloadForm()
    }

}
