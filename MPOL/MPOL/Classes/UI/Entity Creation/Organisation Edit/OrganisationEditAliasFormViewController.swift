//
//  OrganisationEditAliasFormViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

public class OrganisationEditAliasFormViewController: FormBuilderViewController {

    // MARK: PUBLIC

    public var viewModel: OrganisationEditAliasFormViewModel

    /// The handler for submitting the data
    public var submitHandler: ((OrganisationAlias?) -> Void)?

    public init(viewModel: OrganisationEditAliasFormViewModel, submitHandler: ((OrganisationAlias?) -> Void)?) {
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
        if viewModel.organisationAlias == nil {
            viewModel.organisationAlias = OrganisationAlias(id: UUID().uuidString)
        }

        builder += DropDownFormItem()
            .title(NSLocalizedString("Alias Type", comment: ""))
            .options(OrganisationEditAliasFormViewModel.aliasOptions)
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Select", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .selectedValue(viewModel.selectedType != nil ? [viewModel.selectedType!] : [])
            .onValueChanged { [unowned self] value in
                self.viewModel.selectedType = value?.first
                self.reloadForm()
            }
            .width(.column(1))

        guard let type = viewModel.selectedType?.title?.sizing().string else { return }

        viewModel.organisationAlias?.type = type
        let aliasFormItem = TextFieldFormItem()
            .title(type)
            .text(viewModel.organisationAlias?.alias)
            .required()
            .placeholder(StringSizing(string: NSLocalizedString("Required", comment: ""), font: .preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)))
            .width(.column(1))
            .onValueChanged {
                self.viewModel.organisationAlias?.alias = $0
            }
        builder += aliasFormItem
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
            submitHandler?(viewModel.organisationAlias)
            dismiss(animated: true, completion: nil)
        }
    }

}
