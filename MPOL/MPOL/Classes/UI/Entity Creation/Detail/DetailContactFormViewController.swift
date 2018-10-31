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
        title = NSLocalizedString("Add Contact Details", comment: "")
        if viewModel.contact == nil {
            viewModel.contact = Contact(id: UUID().uuidString)
        }
        builder += DropDownFormItem()
            .title(NSLocalizedString("Contact Type", comment: ""))
            .options(Contact.ContactType.allCases.map { $0.localizedDescription() })
            .required()
            .selectedValue(viewModel.selectedType != nil ? [viewModel.selectedType!.localizedDescription()] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first != nil ? Contact.ContactType.contactType(from: value!.first!) : nil
                self.reloadForm()
            }
            .width(.column(1))

        guard let type = viewModel.selectedType else { return }
        viewModel.contact?.type = type
        let formItem = TextFieldFormItem()
            .title(viewModel.selectedType?.localizedDescription())
            .text(viewModel.contact?.value)
            .required()
            .width(.column(1))
            .accessory(ItemAccessory.pencil)
            .onValueChanged {
                self.viewModel.contact?.value = $0
        }
        if viewModel.selectedType == .email {
            formItem.softValidate(EmailSpecification(), message: "Invalid email address")
        }
        builder += formItem
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
