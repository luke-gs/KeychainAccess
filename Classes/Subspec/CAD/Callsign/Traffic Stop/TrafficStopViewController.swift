//
//  TrafficStopViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 4/12/17.
//

import PromiseKit

open class TrafficStopViewController: FormBuilderViewController {
    
    // MARK: - Properties
    
    /// View model of the view controller
    open let viewModel: TrafficStopViewModel
    
    public init(viewModel: TrafficStopViewModel) {
        self.viewModel = viewModel
        super.init()
        
        self.viewModel.delegate = self
        
        setupNavigationBarButtons()
        fetchLocation()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open func fetchLocation() {
        _ = firstly {
            LocationManager.shared.requestPlacemark()
        }.then { [unowned self] placemark -> Void in
            self.viewModel.location = placemark
            self.reloadForm()
        }.catch { _ in
            
        }
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
            .actionButton(title: NSLocalizedString("ADD", comment: "").uppercased(), handler: { [unowned self] _ in
                let addEntityVM = self.viewModel.viewModelForAddingEntity()
                self.navigationController?.pushViewController(addEntityVM.createViewController(), animated: true)
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
            .value(viewModel.formattedLocation())
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
            .placeholder("Required")
            .selectedValue([viewModel.priority?.rawValue].removeNils())
            .onValueChanged({ [unowned self] in
                self.viewModel.priority = IncidentGrade(rawValue: $0?.first ?? "")
            })
            .width(.fixed(100))
        builder += DropDownFormItem(title: "Primary Code")
            .options(viewModel.primaryCodeOptions)
            .required("Primary Code is required")
            .placeholder("Required")
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
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            cancelPromise()
        }
    }
    
    deinit {
        cancelPromise()
    }
    
    private func cancelPromise() {
        // Cancel promise if it's not cancelled
        if viewModel.promise.promise.isPending {
            viewModel.cancel()
        }
    }
    
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


extension TrafficStopViewController: TrafficStopViewModelDelegate {
    
    open func reloadData() {
        reloadForm()
    }
}
