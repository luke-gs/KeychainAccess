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
        title = NSLocalizedString("Add Alias", comment: "")
        if viewModel.personAlias == nil {
            viewModel.personAlias = PersonAlias(id: UUID().uuidString)
        }

        builder += DropDownFormItem()
            .title(NSLocalizedString("Title", comment: ""))
            .options(DetailAliasFormViewModel.aliasOptions)
            .required()
            .selectedValue(viewModel.selectedType != nil ? [viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))

        guard let type = viewModel.selectedType?.title else { return }

        viewModel.personAlias?.type = type
        let firstNameFormItem =  TextFieldFormItem()
            .title(NSLocalizedString("First Name", comment: ""))
            .text(viewModel.personAlias?.firstName)
            .width(.column(1))
            .onValueChanged {
                self.viewModel.personAlias?.firstName = $0
            }

        let middleNameFormItem = TextFieldFormItem()
            .title(NSLocalizedString("Middle Name/s", comment: ""))
            .text(viewModel.personAlias?.middleNames)
            .width(.column(1))
            .onValueChanged {
                self.viewModel.personAlias?.middleNames = $0
            }

        let lastNameFormItem = TextFieldFormItem()
            .title(type)
            .text(viewModel.personAlias?.lastName)
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Required", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(1))
            .onValueChanged {
                self.viewModel.personAlias?.lastName = $0
            }
            .onStyled { cell in
                guard let cell = cell as? CollectionViewFormTextFieldCell else { return }
                cell.textField.placeholderTextColor = cell.textField.textColor
            }
        builder += firstNameFormItem
        builder += middleNameFormItem
        builder += lastNameFormItem
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
            submitHandler?(viewModel)
            dismiss(animated: true, completion: nil)
        }
    }

}
