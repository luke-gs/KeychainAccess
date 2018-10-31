//
//  DetailAddressFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class DetailAddressFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: DetailAddressFormViewModel

    public init(viewModel: DetailAddressFormViewModel) {
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
                        self.viewModel.detailType = addressType
                    } else {
                        self.viewModel.detailType = .empty
                    }
                } else {
                    self.viewModel.detailType = .empty
                }
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))
        switch viewModel.detailType {
        case .residential, .work:
            builder += TextFieldFormItem()
                .title("Remarks")
                .width(.column(1))
                .onValueChanged {
                    self.viewModel.locationRemark = $0
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

    @objc open func didTapCancelButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc open func didTapDoneButton(_ button: UIBarButtonItem) {
        let result = builder.validate()
        switch result {
        case .invalid:
            builder.validateAndUpdateUI()
        case .valid:
            viewModel.delegate?.onComplete(type: self.viewModel.detailType,
                                           location: self.viewModel.selectedLocation!,
                                           remark: self.viewModel.locationRemark)
            dismiss(animated: true, completion: nil)
        }
    }

}
