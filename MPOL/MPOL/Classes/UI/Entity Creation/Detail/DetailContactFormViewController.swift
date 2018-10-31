//
//  DetailContactFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class DetailContactFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: DetailContactFormViewModel

    public typealias SubmitHandler = (DetailContactFormViewModel) -> Void

    /// The handler for submitting the data
    public var submitHandler: SubmitHandler?

    public init(viewModel: DetailContactFormViewModel, submitHandler: SubmitHandler?) {
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
        title = AssetManager.shared.string(forKey: .addContactFormTitle)
        self.viewModel.contact = Contact(id: UUID().uuidString)
        builder += DropDownFormItem()
            .title("Contact Type")
            .options(DetailCreationContactType.allCase)
            .required()
            .selectedValue(self.viewModel.selectedType != nil ? [self.viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                if let value = value?.first, let contactType = DetailCreationContactType(rawValue: value) {
                    self.viewModel.detailType = contactType
                } else {
                    self.viewModel.detailType = .empty
                }
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))
        if self.viewModel.detailType != .empty {
            let formItem = TextFieldFormItem()
                .title(self.viewModel.detailType.rawValue)
                .required()
                .width(.column(1))
                .accessory(ItemAccessory.pencil)
                .onValueChanged {
                    switch self.viewModel.detailType {
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
            if self.viewModel.detailType == .email {
                formItem.softValidate(EmailSpecification(), message: "Invalid email address")
            }
            builder += formItem
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
