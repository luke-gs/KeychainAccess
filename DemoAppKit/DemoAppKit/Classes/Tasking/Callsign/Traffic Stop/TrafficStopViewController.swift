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
        LocationManager.shared.requestPlacemark().done { [weak self] (placemark) in
            self?.viewModel.location = LocationSelection(placemark: placemark)
            self?.reloadForm()
        }.recover { [weak self] _ in
            // Fallback to using last location, if known
            if let location = LocationManager.shared.lastLocation {
                self?.viewModel.location = LocationSelection(coordinate: location.coordinate, addressString: nil)
                self?.reloadForm()
            }
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

        // Stop Detail Form Items

        builder += LargeTextHeaderFormItem(text: "Stop Details")
            .separatorColor(.clear)

        let locationSelectionViewModel = LocationSelectionMapViewModel()
        if let location = viewModel.location {
            locationSelectionViewModel.location = location
            locationSelectionViewModel.dropsPinAutomatically = (location.addressString != nil)
        }

        builder += PickerFormItem(pickerAction: LocationSelectionFormAction(viewModel: locationSelectionViewModel, modalPresentationStyle: .none))
            .title(NSLocalizedString("Location", comment: ""))
            .width(.column(1))
            .required("Location is required.")
            .selectedValue(viewModel.location)
            .onValueChanged({ [unowned self] (location) in
                self.viewModel.location = location
            })

        builder += OptionFormItem()
            .title("Create an incident".sizing(withNumberOfLines: 0, font: UIFont.systemFont(ofSize: 15, weight: .semibold)))
            .isChecked(viewModel.createIncident)
            .onValueChanged({ [unowned self] in
                self.viewModel.createIncident = $0
                self.reloadForm()
            })
            .width(.column(1))

        // Incident Details Form Items

        if viewModel.createIncident {

            builder += LargeTextHeaderFormItem(text: "Incident Details")
                .separatorColor(.clear)

            builder += DropDownFormItem(title: "Priority")
                .options(viewModel.priorityOptions)
                .required("Priority is required")
                .placeholder("Required")
                .selectedValue([viewModel.priority?.rawValue].removeNils())
                .onValueChanged({ [unowned self] in
                    self.viewModel.priority = CADClientModelTypes.incidentGrade.init(rawValue: $0?.first ?? "")
                })
                .width(.column(3))

            builder += DropDownFormItem(title: "Primary Code")
                .options(viewModel.primaryCodeOptions)
                .required("Primary Code is required")
                .placeholder("Required")
                .selectedValue([viewModel.primaryCode].removeNils())
                .onValueChanged({ [unowned self] in
                    self.viewModel.primaryCode = $0?.first
                })
                .width(.column(3))

            builder += DropDownFormItem(title: "Secondary Code")
                .options(viewModel.secondaryCodeOptions)
                .selectedValue([viewModel.secondaryCode].removeNils())
                .placeholder("Optional")
                .onValueChanged({ [unowned self] in
                    self.viewModel.secondaryCode = $0?.first
                })
                .width(.column(3))

            builder += TextFieldFormItem(title: "Remark")
                .text(viewModel.remark)
                .placeholder("optional")
                .onValueChanged({ [unowned self] in
                    self.viewModel.remark = $0
                })
                .width(.column(1))
        }

        // Entity Form Items

        builder += LargeTextHeaderFormItem(text: "Stopped Subjects")
            .separatorColor(.clear)
            .actionButton(title: NSLocalizedString("Add", comment: ""), handler: { [unowned self] _ in
                let entityViewModel = self.viewModel.viewModelForAddingEntity()
                self.present(BookOnScreen.trafficStopEntity(entityViewModel: entityViewModel))
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
        if viewModel.completionHandler != nil {
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
