//
//  DetailCreationViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

/// Displays creation form for details
public class DetailCreationViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: DetailCreationViewModel

    public init(viewModel: DetailCreationViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AssetManager.shared.string(forKey: .submitFormCancel),
                                                           style: .plain, target: self, action: #selector(didTapCancelButton(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AssetManager.shared.string(forKey: .submitFormDone),
                                                            style: .done, target: self, action: #selector(didTapDoneButton(_:)))
    }

    public override func construct(builder: FormBuilder) {
        switch viewModel.detailType {
        case .contact(let type):
            title = AssetManager.shared.string(forKey: .addContactFormTitle)
            self.viewModel.contact = Contact(id: UUID().uuidString)
            builder += DropDownFormItem()
                .title("Contact Type")
                .options(DetailCreationContactType.allCase)
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first, let contactType = DetailCreationContactType(rawValue: value) {
                        self.viewModel.detailType = DetailCreationType.contact(contactType)
                    } else {
                        self.viewModel.detailType = DetailCreationType.contact(.empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))
            if type != .empty {
                let formItem = TextFieldFormItem()
                    .title(type.rawValue)
                    .required()
                    .width(.column(1))
                    .accessory(ItemAccessory.pencil)
                    .onValueChanged {
                        switch type {
                        case .number:
                            self.viewModel.contact?.type = .phone
                        case .mobile:
                            self.viewModel.contact?.type = .mobile
                        case .email:
                            self.viewModel.contact?.type = .email
                        default:
                            break
                        }
                        self.viewModel.contact?.value = $0
                }
                if type == .email {
                    formItem.softValidate(EmailSpecification(), message: "Invalid email address")
                }
                builder += formItem
            }
        case .alias(let type):
            title = AssetManager.shared.string(forKey: .addAliasFormTitle)
            self.viewModel.personAlias = PersonAlias(id: UUID().uuidString)
            builder += DropDownFormItem()
                .title("Type")
                .options(DetailCreationAliasType.allCase)
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first {
                        if let aliasType = DetailCreationAliasType(rawValue: value) {
                            self.viewModel.detailType = DetailCreationType.alias(aliasType)
                        } else {
                            // Use others for unrecognised types
                            self.viewModel.detailType = DetailCreationType.alias(.others)
                        }
                    } else {
                        self.viewModel.detailType = DetailCreationType.alias(.empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))

            switch type {
            case .maiden, .preferredName:
                self.viewModel.personAlias?.type = type.rawValue
                builder += TextFieldFormItem()
                    .title("First Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        self.viewModel.personAlias?.firstName = $0
                }
                builder += TextFieldFormItem()
                    .title("Middle Name/s")
                    .width(.column(1))
                    .onValueChanged {
                        self.viewModel.personAlias?.middleNames = $0
                }
                let lastNameFormItem = TextFieldFormItem()
                    .title("Last Name")
                    .width(.column(1))
                    .onValueChanged {
                        self.viewModel.personAlias?.lastName = $0
                }
                if type == .maiden {
                    lastNameFormItem.required()
                }
                builder += lastNameFormItem
            case .nickname, .formerName, .knownAs, .others:
                self.viewModel.personAlias?.type = type.rawValue
                builder += TextFieldFormItem()
                    .title("Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        self.viewModel.personAlias?.nickname = $0
                }
            case .empty:
                break
            }
        case .address(let type):
            title = AssetManager.shared.string(forKey: .addAddressFormTitle)
            builder += LargeTextHeaderFormItem()
                .text("General")

            builder += DropDownFormItem()
                .title("Type")
                .options(DetailCreationAddressType.allCase)
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first {
                        if let addressType = DetailCreationAddressType(rawValue: value) {
                            self.viewModel.detailType = DetailCreationType.address(addressType)
                        } else {
                            self.viewModel.detailType = DetailCreationType.address(.empty)
                        }
                    } else {
                        self.viewModel.detailType = DetailCreationType.address(.empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))

            switch type {
            case .residential, .work:
                builder += TextFieldFormItem()
                    .title("Remarks")
                    .width(.column(1))
                    .onValueChanged {
                        // TODO: change
                        _ = $0
                }
                builder += LargeTextHeaderFormItem()
                    .text("Address")
                builder += PickerFormItem(pickerAction: LocationSelectionFormAction())
                    .title(AssetManager.shared.string(forKey: .addAddressFormLocation))
                    .width(.column(1))
                    .required()
                    .onValueChanged({ [unowned self] (location) in
                        self.viewModel.selectedLocation = location
                    })
            case .empty:
                break
            }
        }
    }

    @objc open func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc open func didTapDoneButton(_ button: UIBarButtonItem) {
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            switch viewModel.detailType {
            case .contact:
                viewModel.delegate?.onComplete(contact: self.viewModel.contact!)
            case .alias:
                viewModel.delegate?.onComplete(alias: self.viewModel.personAlias!)
            case .address(let type):
                viewModel.delegate?.onComplete(type: type, location: self.viewModel.selectedLocation!)
            }
            dismiss(animated: true, completion: nil)
        }
    }
}
