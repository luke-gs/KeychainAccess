//
//  OrganisationEditContactFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

public class OrganisationEditContactFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: OrganisationEditContactFormViewModel

    /// The handler for submitting the data
    public var submitHandler: ((Contact?) -> Void)?

    public init(viewModel: OrganisationEditContactFormViewModel, submitHandler: ((Contact?) -> Void)?) {
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
            .options(Contact.ContactType.allCases.map { AnyPickable($0) })
            .required()
            .selectedValue(viewModel.selectedType != nil ? [AnyPickable(viewModel.selectedType!)] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first?.base as? Contact.ContactType
                self.viewModel.contact?.value = nil
                self.reloadForm()
            }
            .width(.column(1))

        guard let type = viewModel.selectedType else { return }
        viewModel.contact?.type = type
        let formItem = TextFieldFormItem()
            .title(viewModel.selectedType?.title)
            .text(viewModel.contact?.value)
            .required()
            .width(.column(1))
            .accessory(ItemAccessory.pencil)
            .onValueChanged {
                self.viewModel.contact?.value = $0
            }
        if viewModel.selectedType == .email {
            formItem.softValidate(EmailSpecification(), message: "Invalid email address")
            formItem.keyboardType(.emailAddress)
        } else {
            formItem.keyboardType(.phonePad)
        }
        builder += formItem
        builder += TextFieldFormItem()
            .title(NSLocalizedString("Remarks", comment: ""))
            .text(viewModel.contact?.remark)
            .width(.column(1))
            .onValueChanged {
                self.viewModel.contact?.remark = $0
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
            submitHandler?(viewModel.contact)
            dismiss(animated: true, completion: nil)
        }
    }

}
