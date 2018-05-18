//
//  CreateIncidentViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class CreateIncidentViewController: SubmissionFormBuilderViewController {

    open let viewModel: CreateIncidentViewModel

    public init(viewModel: CreateIncidentViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    // MARK: - View lifecycle

    open override func viewDidLoad() {
        // Set super properties
        title = viewModel.navTitle()
        loadingManager.errorView.titleLabel.text = NSLocalizedString("Failed to Create Incident", comment: "")

        super.viewDidLoad()
    }

    /// Perform actual submit logic
    open override func performSubmit() -> Promise<Void> {
        return viewModel.submitForm()
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {

        let statusViewModel = viewModel.statusViewModel

        // Show callsign statuses
        for sectionIndex in 0..<statusViewModel.numberOfSections() {
            // Show header if text
            if let headerText = statusViewModel.headerText(at: sectionIndex), !headerText.isEmpty {
                builder += HeaderFormItem(text: headerText)
            }

            // Add each status item
            for rowIndex in 0..<statusViewModel.numberOfItems(for: sectionIndex) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                if let item = statusViewModel.item(at: indexPath) {
                    builder += CallsignStatusFormItem(text: item.title, image: item.image)
                        .layoutMargins(UIEdgeInsets(top: 16.0, left: 24.0, bottom: 0.0, right: 24.0))
                        .selected(statusViewModel.selectedIndexPath == indexPath)
                        .onSelection { [weak self] cell in
                            self?.selectCallsignStatus(at: indexPath)
                    }
                }
            }
        }

        builder += HeaderFormItem(text: NSLocalizedString("Incident Details", comment: "").uppercased())

        builder += DropDownFormItem(title: NSLocalizedString("Priority", comment: ""))
            .options(viewModel.priorityOptions)
            .selectedValue([viewModel.contentViewModel.priority?.rawValue].removeNils())
            .placeholder("Select")
            .required("Priority is required.")
            .allowsMultipleSelection(false)
            .width(.column(4))
            .onValueChanged { [unowned self] in
                if let value = $0?.first {
                    self.viewModel.contentViewModel.priority = CADClientModelTypes.incidentGrade.init(rawValue: value)
                }
        }

        builder += DropDownFormItem(title: NSLocalizedString("Primary Code", comment: ""))
            .options(viewModel.primaryCodeOptions)
            .selectedValue([viewModel.contentViewModel.primaryCode].removeNils())
            .placeholder("Select")
            .required("Primary Code is required.")
            .allowsMultipleSelection(false)
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.primaryCode = $0?.first
        }

        builder += DropDownFormItem(title: NSLocalizedString("Secondary Code", comment: ""))
            .options(viewModel.secondaryCodeOptions)
            .selectedValue([viewModel.contentViewModel.secondaryCode].removeNils())
            .allowsMultipleSelection(false)
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.secondaryCode = $0?.first
        }

        builder += ValueFormItem() // TODO: Implement selecting location
            .title(NSLocalizedString("Address", comment: ""))
            .value(viewModel.contentViewModel.location)
            .accessory(FormAccessoryView(style: .disclosure))
            .width(.column(1))

        builder += TextFieldFormItem(title: NSLocalizedString("Description", comment: ""))
            .placeholder("Required")
            .text(viewModel.contentViewModel.description)
            .required("Description is required")
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.description = $0
            }
            .width(.column(1))

        builder += HeaderFormItem(text: NSLocalizedString("Informant Details", comment: "").uppercased())
        builder += TextFieldFormItem(title: NSLocalizedString("Full Name", comment: ""))
            .placeholder("Required")
            .text(viewModel.contentViewModel.informantName)
            .required("Name is required")
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.informantName = $0
            }
            .width(.column(2))

        builder += TextFieldFormItem(title: NSLocalizedString("Contact Number", comment: ""))
            .required("A contact number is required")
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Contact number must be a number")
            .text(viewModel.contentViewModel.informantPhone)
            .keyboardType(.numberPad)
            .onValueChanged { [unowned self] in
                self.viewModel.contentViewModel.informantPhone = $0
            }
            .width(.column(2))
    }

    open func selectCallsignStatus(at indexPath: IndexPath) {
        let statusViewModel = viewModel.statusViewModel
        guard indexPath != statusViewModel.selectedIndexPath else { return }

        // Update the selected index path and process any user input required
        firstly {
            return statusViewModel.setSelectedIndexPath(indexPath)
        }.done { [weak self] _ in
            self?.reloadForm()
        }.catch { error in
            AlertQueue.shared.addErrorAlert(message: error.localizedDescription)
        }
    }

}

extension CreateIncidentViewController: CreateIncidentViewModelDelegate {
    public func contentChanged() {
        reloadForm()
    }
}
