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
            // TODO: use Asset Manager
            title = "Add Contact Details"
            builder += DropDownFormItem()
                .title("Contact Type")
                .options(DetailCreationContactType.allCase())
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first, let contactType = DetailCreationContactType(rawValue: value) {
                        self.viewModel.detailType = DetailCreationType.contact(contactType)
                    } else {
                        self.viewModel.detailType = DetailCreationType.contact(.Empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))
            if type != .Empty {
                builder += TextFieldFormItem()
                    .title(type.rawValue)
                    .required()
                    .width(.column(1))
            }
        case .alias(let type):
            title = "Add Alias"
            builder += DropDownFormItem()
                .title("Type")
                .options(DetailCreationAliasType.allCase())
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first {
                        if let aliasType = DetailCreationAliasType(rawValue: value) {
                            self.viewModel.detailType = DetailCreationType.alias(aliasType)
                        } else {
                            // Use Others for unrecognised types
                            self.viewModel.detailType = DetailCreationType.alias(.Others)
                        }

                    } else {
                        self.viewModel.detailType = DetailCreationType.alias(.Empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))

            switch type {
            case .Maiden, .PreferredName:
                builder += TextFieldFormItem()
                    .title("First Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        _ = $0
                }
                builder += TextFieldFormItem()
                    .title("Middle Name/s")
                    .width(.column(1))
                    .onValueChanged {
                        _ = $0
                }
                let lastNameFormItem = TextFieldFormItem()
                    .title("Last Name")
                    .width(.column(1))
                    .onValueChanged {
                        _ = $0
                }
                if type == .Maiden {
                    lastNameFormItem.required()
                }
                builder += lastNameFormItem
            case .Nickname, .Others:
                builder += TextFieldFormItem()
                    .title("Name")
                    .width(.column(1))
                    .required()
                    .onValueChanged {
                        _ = $0
                }
            case .Empty:
                break
            }
        case .address(let type):
            title = "Add Address"
            builder += LargeTextHeaderFormItem()
                .text("General")

            builder += DropDownFormItem()
                .title("Type")
                .options(DetailCreationAddressType.allCase())
                .required()
                .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
                .onValueChanged { [unowned self] value in
                    if let value = value?.first {
                        if let addressType = DetailCreationAddressType(rawValue: value) {
                            self.viewModel.detailType = DetailCreationType.address(addressType)
                        } else {
                            // Use Others for unrecognised types
                            self.viewModel.detailType = DetailCreationType.address(.Empty)
                        }
                    } else {
                        self.viewModel.detailType = DetailCreationType.address(.Empty)
                    }
                    self.viewModel.selectedType = value?.first
                    self.reloadForm()
                }
                .width(.column(1))

            switch type {
            case .Residential, .Work:
                builder += TextFieldFormItem()
                    .title("Remarks")
                    .width(.column(1))
                    .onValueChanged {
                        _ = $0
                }
                builder += LargeTextHeaderFormItem()
                    .text("Address")
                builder += PickerFormItem(pickerAction: LocationSelectionFormAction())
                    .title(AssetManager.shared.string(forKey: .trafficStopLocation))
                    .width(.column(1))
                    .required()
                    .onValueChanged({ [unowned self] (location) in
                        self.viewModel.selectedLocation = location
                    })
            case .Empty:
                break
            }
        }
    }

    @objc public func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc open func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: PRIVATE

}
