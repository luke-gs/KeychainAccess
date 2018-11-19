//
//  PersonEditAliasFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class PersonEditAliasFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: PersonEditAliasFormViewModel

    /// The handler for submitting the data
    public var submitHandler: ((PersonAlias?) -> Void)?

    public init(viewModel: PersonEditAliasFormViewModel, submitHandler: ((PersonAlias?) -> Void)?) {
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
            .title(NSLocalizedString("Alias Type", comment: ""))
            .options(PersonEditAliasFormViewModel.aliasOptions)
            .required()
            .selectedValue(viewModel.selectedType != nil ? [viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))

        guard let type = viewModel.selectedType?.title?.sizing().string else { return }

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
            .width(.column(1))
            .onValueChanged {
                self.viewModel.personAlias?.lastName = $0
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
            submitHandler?(viewModel.personAlias)
            dismiss(animated: true, completion: nil)
        }
    }

}
