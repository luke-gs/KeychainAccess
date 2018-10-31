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
        self.viewModel.personAlias = PersonAlias(id: UUID().uuidString)
        builder += DropDownFormItem()
            .title("Type")
            .options(DetailCreationAliasType.allCase)
            .required()
            .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                if let value = value?.first {
                    if let aliasType = DetailCreationAliasType(rawValue: value) {
                        self.viewModel.detailType = aliasType
                    } else {
                        // Use others for unrecognised types
                        self.viewModel.detailType = .others
                    }
                } else {
                    self.viewModel.detailType = .empty
                }
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))

        switch self.viewModel.detailType {
        case .maiden, .preferredName:
            self.viewModel.personAlias?.type = self.viewModel.detailType.rawValue
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
            if self.viewModel.detailType == .maiden {
                lastNameFormItem.required()
            }
            builder += lastNameFormItem
        case .nickname, .formerName, .knownAs, .others:
            self.viewModel.personAlias?.type = self.viewModel.detailType.rawValue
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
