//
//  OrganisationEditViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class OrganisationEditViewController: FormBuilderViewController {

    // MARK: - Storage

    private var finalOrganisation = Organisation(id: UUID().uuidString)

    public init(initialOrganisation: Organisation? = nil) {
        if let initialOrganisation = initialOrganisation {
            self.finalOrganisation = initialOrganisation
        }
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtonTapped(_:)))
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func construct(builder: FormBuilder) {
        builder.title = NSLocalizedString("Create New Organisation", comment: "Nav Title")

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: "Details Section Header")).separatorColor(.clear)

        if let items = Manifest.shared.entries(for: .organisationType)?.rawValues() {
            builder += DropDownFormItem()
                .title(NSLocalizedString("Organisation Type", comment: "Drop Down Title"))
                .options(items)
                .required()
                .width(.column(4))
        }

        builder += TextFieldFormItem().title(NSLocalizedString("Organisation Name", comment: "Title"))
            .required()
            .width(.column(4))

        builder += TextFieldFormItem().title(NSLocalizedString("ABN", comment: "Title"))
            .width(.column(4))

        builder += TextFieldFormItem().title(NSLocalizedString("ACN", comment: "Title"))
            .width(.column(4))

        // Contact section
        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Contact Details", comment: ""))
            .actionButton(title: NSLocalizedString("Add", comment: ""), handler: { [unowned self] _ in
                self.present(
                    EntityScreen.createOrganisationContactDetail(contact: nil,
                                                           submitHandler: { [unowned self] contact in
                                                            guard let contact = contact else { return }
                                                            if self.finalOrganisation.contacts != nil {
                                                                self.finalOrganisation.contacts!.append(contact)
                                                            } else {
                                                                self.finalOrganisation.contacts = [contact]
                                                            }
                                                            self.reloadForm()
                    }))
            })

        if let contacts = finalOrganisation.contacts {
            for (index, contact) in contacts.enumerated() {
                let formItem = ValueFormItem()
                    .title(contact.type?.title)
                    .value(contact.value)
                    .width(.column(1))
                    .accessory(ItemAccessory.pencil)
                    .editActions([CollectionViewFormEditAction(title: NSLocalizedString("Remove", comment: ""),
                                                               color: UIColor.red,
                                                               handler: { [unowned self] (_, _) in
                                                                self.finalOrganisation.contacts?.remove(at: index)
                                                                self.reloadForm()
                    })])
                    .onSelection { [unowned self] _ in
                        self.present(
                            EntityScreen.createOrganisationContactDetail(contact: contact,
                                                                   submitHandler: { [unowned self] contact in
                                                                    guard let contact = contact else { return }
                                                                    self.finalOrganisation.contacts?[index] = contact
                                                                    self.reloadForm()
                            }))
                }
                builder += formItem
            }
        }

        // Alias section
        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Aliases", comment: ""))
            .actionButton(title: NSLocalizedString("Add", comment: ""), handler: { [unowned self] _ in
                self.present(
                    EntityScreen.createOrganisationAliasDetail(alias: nil,
                                                         submitHandler: { [unowned self] organisationAlias in
                                                            guard let organisationAlias = organisationAlias else { return }
                                                            if self.finalOrganisation.aliases != nil {
                                                                self.finalOrganisation.aliases!.append(organisationAlias)
                                                            } else {
                                                                self.finalOrganisation.aliases = [organisationAlias]
                                                            }
                                                            self.reloadForm()
                    }))
            })

        if let aliases = finalOrganisation.aliases {
            for (index, alias) in aliases.enumerated() {
                let formItem = ValueFormItem()
                    .title(alias.type?.title)
                    .value(alias.alias)
                    .width(.column(1))
                    .accessory(ItemAccessory.pencil)
                    .editActions([CollectionViewFormEditAction(title: NSLocalizedString("Remove", comment: ""),
                                                               color: UIColor.red,
                                                               handler: { [unowned self] (_, _) in
                                                                self.finalOrganisation.contacts?.remove(at: index)
                                                                self.reloadForm()
                    })])
                    .onSelection { [unowned self] _ in
                        self.present(
                            EntityScreen.createOrganisationAliasDetail(alias: alias,
                                                                         submitHandler: { [unowned self] alias in
                                                                            guard let alias = alias else { return }
                                                                            self.finalOrganisation.aliases?[index] = alias
                                                                            self.reloadForm()
                            }))
                }
                builder += formItem
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
            do {
                try UserSession.current.userStorage?.addEntity(object: finalOrganisation,
                                                               key: UserStorage.CreatedEntitiesKey,
                                                               notification: NSNotification.Name.CreatedEntitiesDidUpdate)
            } catch {
                // TODO: Handles error if it cannot be saved
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

}
