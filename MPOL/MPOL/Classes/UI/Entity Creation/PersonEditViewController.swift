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

    // MARK: - Storage

    private var finalPerson = Person(id: UUID().uuidString)
    private let finalDescription = PersonDescription(id: UUID().uuidString)

    private var locations: [(AnyPickable, LocationSelectionType)]?

    private let numberFormatter = NumberFormatter()

    // MARK: - Initializer

    public init(initialPerson: Person? = nil) {
        if let initialPerson = initialPerson {
            self.finalPerson = initialPerson
        }
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtonTapped(_:)))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func construct(builder: FormBuilder) {

        builder.title = "Person"

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("General", comment: "")).separatorColor(.clear)

        builder += TextFieldFormItem()
            .title(NSLocalizedString("First Name", comment: ""))
            .text(finalPerson.givenName)
            .onValueChanged { self.finalPerson.givenName = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Middle Name/s", comment: ""))
            .text(finalPerson.middleNames)
            .onValueChanged { self.finalPerson.middleNames = $0 }
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Last Name", comment: ""))
            .text(finalPerson.familyName)
            .onValueChanged { self.finalPerson.familyName = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Identification Number", comment: ""))
            .text(finalPerson.identificationNumber)
            .width(.column(4))
            .onValueChanged { [unowned self] value in
                self.finalPerson.identificationNumber = value
        }

        builder += DateFormItem()
            .title(NSLocalizedString("Date Of Birth", comment: ""))
            .dateFormatter(.preferredDateStyle)
            .selectedValue(finalPerson.dateOfBirth)
            .onValueChanged { self.finalPerson.dateOfBirth = $0 }
            .required()
            .width(.column(4))

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Place of Birth", comment: ""))
            .text(finalPerson.placeOfBirth)
            .width(.column(4))
            .onValueChanged { [unowned self] value in
                self.finalPerson.placeOfBirth = value
        }

        builder += TextFieldFormItem()
            .title(NSLocalizedString("Ethnicity", comment: ""))
            .text(finalDescription.ethnicity)
            .width(.column(4))
            .onValueChanged { [unowned self] value in
                self.finalDescription.ethnicity = value
        }

        builder += DropDownFormItem()
            .title(NSLocalizedString("Gender", comment: ""))
            .options(Person.Gender.allCases)
            .selectedValue(finalPerson.gender != nil
                ? [finalPerson.gender!]
                : nil)
            .onValueChanged { self.finalPerson.gender = $0?.first }
            .width(.column(4))

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Physical Description", comment: "")).separatorColor(.clear)

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
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Height can only be number.", comment: ""))
            .strictValidate(CountSpecification.max(3), message: NSLocalizedString("Maximum number of characters reached.", comment: ""))
            .width(.column(4))

        builder += TextFieldFormItem()
            .title("Weight (kg)")
            .text(finalDescription.weight != nil ? String(finalDescription.weight!) : nil)
            .placeholder("0 kg")
            .onValueChanged { self.finalDescription.weight = $0 }
            .strictValidate(CharacterSetSpecification.decimalDigits, message: NSLocalizedString("Weight can only be number.", comment: ""))
            .strictValidate(CountSpecification.max(3), message: NSLocalizedString("Maximum number of characters reached.", comment: ""))
            .width(.column(4))

        if let items = Manifest.shared.entries(for: .personBuild)?.rawValues() {
            builder += DropDownFormItem()
                .title(NSLocalizedString("Build", comment: ""))
                .options(items)
                .selectedValue(finalDescription.build != nil ? [finalDescription.build!] : nil)
                .onValueChanged { self.finalDescription.build = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personRace)?.rawValues() {
            builder += DropDownFormItem()
                .title(NSLocalizedString("Race", comment: ""))
                .options(items)
                .selectedValue(finalDescription.race != nil ? [finalDescription.race!] : nil)
                .onValueChanged { self.finalDescription.race = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personEyeColour)?.rawValues() {
            builder += DropDownFormItem()
                .title(NSLocalizedString("Eye Colour", comment: ""))
                .options(items)
                .selectedValue(finalDescription.eyeColour != nil ? [finalDescription.eyeColour!] : nil)
                .onValueChanged { self.finalDescription.eyeColour = $0?.first }
                .width(.column(4))
        }

        if let items = Manifest.shared.entries(for: .personHairColour)?.rawValues() {
            builder += DropDownFormItem()
                .title(NSLocalizedString("Hair Colour", comment: ""))
                .options(items)
                .selectedValue(finalDescription.hairColour != nil ? [finalDescription.hairColour!] : nil)
                .onValueChanged { self.finalDescription.hairColour = $0?.first }
                .width(.column(4))
        }

        builder += TextFieldFormItem()
            .title("Remarks")
            .text(finalDescription.remarks)
            .width(.column(2))
            .onValueChanged { self.finalDescription.remarks = $0 }

        // Contact Section

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Contact Details", comment: ""))
            .actionButton(title: "Add", handler: { [unowned self] _ in
                self.present(EntityScreen.createEntityContactDetail { [unowned self] viewModel in
                    guard let contact = viewModel.contact else { return }
                    if self.finalPerson.contacts != nil {
                        self.finalPerson.contacts!.append(contact)
                    } else {
                        self.finalPerson.contacts = [contact]
                    }
                    self.reloadForm()
                })
            })

        if let contacts = finalPerson.contacts {
            for (index, contact) in contacts.enumerated() {
                let formItem = ValueFormItem()
                    .title(contact.type?.localizedDescription())
                    .value(contact.value)
                    .width(.column(1))
                    .accessory(ItemAccessory.pencil)
                    .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { [unowned self] (_, _) in
                        self.finalPerson.contacts?.remove(at: index)
                        self.reloadForm()
                    })])
                builder += formItem
            }
        }

        // Alias Section

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Aliases", comment: ""))
            .actionButton(title: "Add", handler: { _ in
                self.present(EntityScreen.createEntityAliasDetail { [unowned self] viewModel in
                    guard let personAlias = viewModel.personAlias else { return }
                    if self.finalPerson.aliases != nil {
                        self.finalPerson.aliases!.append(personAlias)
                    } else {
                        self.finalPerson.aliases = [personAlias]
                    }
                    self.reloadForm()
                })
            })

        if let aliases = finalPerson.aliases {
            for (index, alias) in aliases.enumerated() {
                if let nickname = alias.nickname {
                    builder += TextFieldFormItem()
                        .title(alias.type)
                        .text(nickname)
                        .required()
                        .width(.column(1))
                        .onValueChanged { [unowned self] value in
                            self.finalPerson.aliases?[index].nickname = value
                    }
                } else {
                    builder += ValueFormItem()
                        .title(alias.type)
                        .value((alias.lastName != nil ? "\(alias.lastName!)," : "")
                            + alias.firstName!
                            + (alias.middleNames ?? ""))
                        .width(.column(1))
                        .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { [unowned self] (_, _) in
                            self.finalPerson.aliases?.remove(at: index)
                            self.reloadForm()
                        })])
                }
            }
        }

        // Address Section

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Addresses", comment: ""))
            .actionButton(title: "Add", handler: { _ in
                self.present(EntityScreen.createEntityAddressDetail { [unowned self] viewModel in
                    guard let location = viewModel.selectedLocation else { return }
                    if self.locations != nil {
                        self.locations!.append((viewModel.selectedType!, location))
                    } else {
                        self.locations = [(viewModel.selectedType!, location)]
                    }
                    self.reloadForm()
                })
            })
        if let _locations = locations {
            for (index, (type, location)) in _locations.enumerated() {
                builder += PickerFormItem(pickerAction: LocationSelectionFormAction())
                    .title(type.title)
                    .selectedValue(location)
                    .width(.column(1))
                    .required()
                    .onValueChanged { [unowned self] (location) in
                        if let location = location {
                            self.locations?[index] = (type, location)
                        }
                    }
                    .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { [unowned self] (_, _) in
                        self.locations?.remove(at: index)
                        self.reloadForm()
                    })])
            }
        }

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
            if finalPerson.descriptions != nil {
                finalPerson.descriptions!.append(finalDescription)
            } else {
                finalPerson.descriptions = [finalDescription]
            }
            do {
                try UserSession.current.userStorage?.add(object: finalPerson, key: finalPerson.id, flag: UserStorageFlag.session)
            } catch {
                // TODO: Handles error if it cannot be saved
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
