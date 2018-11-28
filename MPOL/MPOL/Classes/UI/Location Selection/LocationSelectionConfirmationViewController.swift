//
//  AddressViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit

public class LocationSelectionConfirmationViewController: FormBuilderViewController {

    public enum FieldType {
        case suburb
        case streetName
    }

    public var doneHandler: ((LocationSelectionConfirmationViewModel) -> Void)?

    public let viewModel: LocationSelectionConfirmationViewModel

    public init(viewModel: LocationSelectionConfirmationViewModel) {
        self.viewModel = viewModel
        super.init()

    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Select Location", comment: "")
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(performDoneAction)), animated: true)
    }

    public override func construct(builder: FormBuilder) {

        // init this here so we can reload in type dropDownItems onValueChanged
        let streetNameItem = TextFieldFormItem()

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: "")).separatorColor(.clear)

        builder += ValueFormItem(title: NSLocalizedString("Address", comment: ""),
                                 value: viewModel.fullAddress)
            .width(.column(1))
            .separatorColor(.clear)

        builder += ValueFormItem(title: NSLocalizedString("Latitude, Longitude", comment: ""),
                                 value: viewModel.coordinateText)
            .width(.column(1))
            .separatorColor(.clear)

        // Only display location type if title, options are defined
        if let title = viewModel.typeTitle, let options = viewModel.typeOptions {
            builder += DropDownFormItem()
                .title(title)
                .options(options)
                .selectedValue(viewModel.selectedTypes)
                .allowsMultipleSelection(viewModel.allowMultipleTypes)
                .required()
                .width(.column(1))
                .onValueChanged { [weak self] value in
                    guard let self = self, let value = value else { return }
                    self.viewModel.selectedTypes = value
                    streetNameItem.required(self.viewModel.fieldRequired[.streetName]?() ?? false)
                    streetNameItem.reloadItem()
                }
        }

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Location Information", comment: "")).separatorColor(.clear)

        // editable

        if viewModel.isEditable {

            builder += TextFieldFormItem(title: NSLocalizedString("Unit / House / Apt. Number", comment: ""))
                .text(viewModel.propertyNumber)
                .onValueChanged { [weak self] in
                    self?.viewModel.propertyNumber = $0
                }
                .width(.column(2))
            builder += TextFieldFormItem(title: NSLocalizedString("Street Number / Range", comment: ""))
                .text(viewModel.streetNumber)
                .onValueChanged { [weak self] in
                    self?.viewModel.streetNumber = $0
                }
                .width(.column(2))
            streetNameItem.title = NSLocalizedString("Street Name", comment: "")
            streetNameItem.text = viewModel.streetName
            streetNameItem.onValueChanged = { [weak self] in
                self?.viewModel.streetName = $0
            }
            streetNameItem.width(.column(2))

            if let streetTypeOptions = viewModel.streetTypeOptions {
                builder += DropDownFormItem(title: NSLocalizedString("Street Type", comment: ""))
                    .options(streetTypeOptions)
                    .selectedValue([viewModel.streetType].removeNils())
                    .allowsMultipleSelection(false)
                    .onValueChanged { [weak self] in
                        self?.viewModel.streetType = $0?.first
                    }
                    .width(.column(2))
            }

            builder += TextFieldFormItem(title: NSLocalizedString("Suburb", comment: ""))
                .text(viewModel.suburb)
                .width(.column(2))
                .onValueChanged { [weak self] in
                    self?.viewModel.suburb = $0
                }
                .required(self.viewModel.fieldRequired[.suburb]?() ?? false)

            builder += streetNameItem

            if let stateOptions = viewModel.stateOptions {
                builder += DropDownFormItem(title: NSLocalizedString("State", comment: ""))
                    .options(stateOptions)
                    .selectedValue([viewModel.state].removeNils())
                    .allowsMultipleSelection(false)
                    .onValueChanged { [weak self] in
                        self?.viewModel.state = $0?.first
                    }
                    .width(.column(2))
            }

            builder += TextFieldFormItem(title: NSLocalizedString("Postcode", comment: ""))
                .text(viewModel.postcode)
                .onValueChanged { [weak self] in
                    self?.viewModel.postcode = $0
                }
                .width(.column(2))

        } else {
            // non-editable

            builder += ValueFormItem(title: NSLocalizedString("Unit / House / Apt. Number", comment: ""),
                                     value: viewModel.propertyNumber)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Number / Range", comment: ""),
                                     value: viewModel.streetNumber)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Name", comment: ""),
                                     value: viewModel.streetName)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Street Type", comment: ""),
                                     value: viewModel.streetType?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Suburb", comment: ""),
                                     value: viewModel.suburb?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("State", comment: ""),
                                     value: viewModel.state?.title)
                .width(.column(2))
                .separatorColor(.clear)
            builder += ValueFormItem(title: NSLocalizedString("Postcode", comment: ""),
                                     value: viewModel.postcode)
                .width(.column(2))
                .separatorColor(.clear)
        }

        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""))
            .onValueChanged { [weak self] in
                self?.viewModel.remarks = $0
            }
            .width(.column(1))
    }
    // MARK: - Done Action
    @objc public func performDoneAction() {
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            doneHandler?(viewModel)
        }
    }
}
