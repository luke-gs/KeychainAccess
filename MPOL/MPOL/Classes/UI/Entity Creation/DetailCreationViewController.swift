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
            self.contact = Contact()
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
                builder += TextFieldFormItem()
                    .title(type.rawValue)
                    .required()
                    .width(.column(1))
                    .accessory(ItemAccessory.pencil)
                    .onValueChanged {
                        switch type {
                        case .number:
                            self.contact?.type = .phone
                        case .mobile:
                            self.contact?.type = .mobile
                        case .email:
                            self.contact?.type = .email
                        default:
                            break
                        }
                        self.contact?.value = $0
                }
            }
        case .alias(let type):
            title = AssetManager.shared.string(forKey: .addAliasFormTitle)
            self.personAlias = PersonAlias()
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
                self.personAlias?.type = type.rawValue
                builder += TextFieldFormItem()
                    .title("First Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        self.personAlias?.firstName = $0
                }
                builder += TextFieldFormItem()
                    .title("Middle Name/s")
                    .width(.column(1))
                    .onValueChanged {
                        self.personAlias?.middleNames = $0
                }
                let lastNameFormItem = TextFieldFormItem()
                    .title("Last Name")
                    .width(.column(1))
                    .onValueChanged {
                        self.personAlias?.lastName = $0
                }
                if type == .maiden {
                    lastNameFormItem.required()
                }
                builder += lastNameFormItem
            case .nickname, .formerName, .knownAs, .others:
                self.personAlias?.type = type.rawValue
                builder += TextFieldFormItem()
                    .title("Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        self.personAlias?.nickname = $0
                }
            case .empty:
                break
            }
        case .address(let type):
            title = AssetManager.shared.string(forKey: .addAddressFormTitle)
            self.address = Address()
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
                            // Use Others for unrecognised types
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
        switch viewModel.detailType {
        case .contact:
            viewModel.delegate?.onCompleteContact(contact: self.contact!)
        case .alias:
            viewModel.delegate?.onCompleteAlias(alias: self.personAlias!)
        case .address:
            viewModel.delegate?.onCompleteAddress(address: self.address!)
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: PRIVATE

    private var contact: Contact?

    private var personAlias: PersonAlias?

    private var address: Address?

}
