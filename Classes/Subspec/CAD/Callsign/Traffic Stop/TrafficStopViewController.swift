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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        
        // Create done button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }
    
    /// Form builder implementation
    open override func construct(builder: FormBuilder) {
        builder.title = viewModel.navTitle()
        
        builder += HeaderFormItem(text: "STOPPED ENTITIES")
            .actionButton(title: NSLocalizedString("ADD", comment: "").uppercased(), handler: { [unowned self] in
                let viewModel = SelectStoppedEntityViewModel()
                viewModel.onSelectEntity = { [unowned self] entity -> Void in
                    if !self.viewModel.entities.contains(entity) {
                        self.viewModel.entities.append(entity)
                    }
                    self.reloadForm()
                }
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
                .editActions([
                    CollectionViewFormEditAction(title: "Remove", color: .orangeRed, handler: { [unowned self] (cell, indexPath) in
                        self.viewModel.entities.remove(at: indexPath.item)
                        self.reloadForm()
                })])
        }
        
        builder += HeaderFormItem(text: "GENERAL")
        builder += ValueFormItem()  // TODO: Implement selecting location
            .title("Location")
            .value(viewModel.location)
            .accessory(FormAccessoryView(style: .disclosure))
            .width(.column(1))
        builder += OptionFormItem()
            .title("Create an incident".sizing(withNumberOfLines: 0, font: UIFont.systemFont(ofSize: 15, weight: .semibold)))
            .isChecked(viewModel.createIncident)
            .onValueChanged({ [unowned self] in
                self.viewModel.createIncident = $0
            })
            .width(.column(1))
        
        builder += HeaderFormItem(text: "INCIDENT DETAILS")
        builder += DropDownFormItem(title: "Priority")
            .options(viewModel.priorityOptions)
            .required("Priority is required")
            .selectedValue([viewModel.priority].removeNils())
            .onValueChanged({ [unowned self] in
                self.viewModel.priority = $0?.first
            })
            .width(.fixed(100))
        builder += DropDownFormItem(title: "Primary Code")
            .options(viewModel.primaryCodeOptions)
            .required("Primary Code is required")
            .selectedValue([viewModel.primaryCode].removeNils())
            .onValueChanged({ [unowned self] in
                self.viewModel.primaryCode = $0?.first
            })
            .width(.fixed(150))
        builder += DropDownFormItem(title: "Secondary Code")
            .options(viewModel.secondaryCodeOptions)
            .selectedValue([viewModel.secondaryCode].removeNils())
            .placeholder("Optional")
            .onValueChanged({ [unowned self] in
                self.viewModel.secondaryCode = $0?.first
            })
            .width(.fixed(150))
        builder += TextFieldFormItem(title: "Remark")
            .text(viewModel.remark)
            .placeholder("Required")
            .required("Remark is required")
            .onValueChanged({ [unowned self] in
                self.viewModel.remark = $0
            })
            .width(.column(1))
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped(_ button: UIBarButtonItem) {
        viewModel.cancel()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneButtonTapped(_ button: UIBarButtonItem) {
        let result = builder.validate()
        
        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            // Let VM do final validation
            let (valid, message) = viewModel.validateForm()
            
            if valid {
                viewModel.submit()
                navigationController?.popViewController(animated: true)
            } else {
                if let message = message {
                    AlertQueue.shared.addErrorAlert(message: message)
                }
            }
        }
    }

}
