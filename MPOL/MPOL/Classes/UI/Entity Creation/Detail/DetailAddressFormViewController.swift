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

    public typealias SubmitHandler = (DetailAddressFormViewModel) -> Void

    /// The handler for submitting the data
    public var submitHandler: SubmitHandler?

    public init(viewModel: DetailAddressFormViewModel, submitHandler: SubmitHandler?) {
        self.viewModel = viewModel
        self.submitHandler = submitHandler
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
            .options(DetailAddressFormViewModel.addressOptions)
            .required()
            .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))

        guard viewModel.selectedType?.title != nil else { return }

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
            .onValueChanged { [unowned self] (location) in
                self.viewModel.selectedLocation = location
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
            submitHandler?(self.viewModel)
            dismiss(animated: true, completion: nil)
        }
    }

}
