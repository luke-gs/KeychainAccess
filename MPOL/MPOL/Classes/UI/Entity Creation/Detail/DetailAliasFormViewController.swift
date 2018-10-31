//
//  DetailAddressFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class DetailAliasFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: DetailAliasFormViewModel

    public typealias SubmitHandler = (DetailAliasFormViewModel) -> Void

    /// The handler for submitting the data
    public var submitHandler: SubmitHandler?

    public init(viewModel: DetailAliasFormViewModel, submitHandler: SubmitHandler?) {
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
        title = AssetManager.shared.string(forKey: .addAliasFormTitle)
        viewModel.personAlias = PersonAlias(id: UUID().uuidString)

        builder += DropDownFormItem()
            .title("Type")
            .options(DetailAliasFormViewModel.aliasOptions)
            .required()
            .selectedValue(viewModel.selectedType != nil ? [viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))
        if let type = viewModel.selectedType?.title {
            viewModel.personAlias?.type = type
            let firstNameFormItem =  TextFieldFormItem()
                .title("First Name")
                .width(.column(1))
                .required()
                .onValueChanged {
                    self.viewModel.personAlias?.firstName = $0
            }

            let middleNameFormItem = TextFieldFormItem()
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
            builder += firstNameFormItem
            builder += middleNameFormItem
            builder += lastNameFormItem
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
