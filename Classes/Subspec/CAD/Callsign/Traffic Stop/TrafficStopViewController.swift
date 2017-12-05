//
//  TrafficStopViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 4/12/17.
//

open class TrafficStopViewController: FormBuilderViewController {
    
    // MARK: - Properties
    
    /// View model of the view controller
    open let viewModel: TrafficStopViewModel
    
    public init(viewModel: TrafficStopViewModel) {
        self.viewModel = viewModel
        super.init()
        
        setupNavigationBarButtons()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
    }
    
    open func setupNavigationBarButtons() {
        // Create cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton(_:)))
        
        // Create done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDoneButton(_:)))
    }
    
    /// Form builder implementation
    open override func construct(builder: FormBuilder) {
        builder.title = viewModel.navTitle()
        
        builder += HeaderFormItem(text: "STOPPED ENTITIES")
            .actionButton(title: NSLocalizedString("ADD", comment: "").uppercased(), handler: { [unowned self] in
                let viewModel = SelectStoppedEntityViewModel()
                self.navigationController?.pushViewController(viewModel.createViewController(), animated: true)
            })
        viewModel.entities.forEach { item in
            builder += SummaryListFormItem()
                .category(item.category)
                .title(item.title)
                .subtitle(item.subtitle)
                .image(item.image)
                .imageTintColor(item.imageColor ?? .primaryGray)
                .borderColor(item.borderColor)
                .width(.column(1))
        }
        
        builder += HeaderFormItem(text: "GENERAL")
        builder += ValueFormItem()
            .title("Location")
            .value("188 Smith Street, Collingwood VIC 3066")
            .accessory(FormAccessoryView(style: .disclosure))
            .width(.column(1))
        builder += OptionFormItem()
            .title("Create an incident".sizing(withNumberOfLines: 0, font: UIFont.systemFont(ofSize: 15, weight: .semibold)))
            .width(.column(1))
        
        builder += HeaderFormItem(text: "INCIDENT DETAILS")
        builder += DropDownFormItem(title: "Priority")
            .options(["P1", "P2", "P3", "P4"])
            .required("Priority is required")
            .selectedValue(["P4"])
            .width(.fixed(100))
        builder += DropDownFormItem(title: "Primary Code")
            .options(["Traffic", "Crash", "Other"])
            .required("Primary Code is required")
            .selectedValue(["Traffic"])
            .width(.fixed(150))
        builder += DropDownFormItem(title: "Secondary Code")
            .options(["Traffic", "Crash", "Other"])
            .placeholder("Optional")
            .width(.fixed(150))
        builder += TextFieldFormItem(title: "Remark")
            .placeholder("Required")
            .required("Remark is required")
            .width(.column(1))
    }
    
    // MARK: - Actions
    
    @objc private func didTapCancelButton(_ button: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapDoneButton(_ button: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

}
