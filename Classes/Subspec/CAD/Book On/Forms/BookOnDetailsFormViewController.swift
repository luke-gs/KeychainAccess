//
//  BookOnDetailsFormViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View controller for the book on details form screen
open class BookOnDetailsFormViewController: FormBuilderViewController {

    private var viewModel: BookOnDetailsFormViewModel

    // MARK: - Initializers

    public init(viewModel: BookOnDetailsFormViewModel) {
        self.viewModel = viewModel
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelFormTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(submitFormTapped))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
        }, completion: nil)
    }

    // MARK: - Form

    private lazy var serialItem: BaseFormItem = {
        let title = NSLocalizedString("Serial", comment: "")
        if self.viewModel.isEditing {
            return ValueFormItem(title: title, value: viewModel.details.serial)
                .width(.column(3))
        } else {
            return TextFieldFormItem(title: title, text: nil)
                .width(.column(3))
                .required("Serial is required.")
                .strictValidate(CharacterSetSpecification.decimalDigits, message: "Serial must be a number")
                .text(viewModel.details.serial)
                .onValueChanged { [weak self] in
                    self?.viewModel.details.serial = $0
            }
        }
    }()

    private lazy var categoryItem: BaseFormItem = {
        let title = NSLocalizedString("Category", comment: "")
        if self.viewModel.isEditing {
            return ValueFormItem(title: title, value: viewModel.details.category)
                .width(.column(3))
        } else {
            return DropDownFormItem(title: title)
                .options(["1", "2", "3"])
                .required()
                .width(.column(3))
                .selectedValue([viewModel.details.category].removeNils())
                .onValueChanged { [weak self] in
                    self?.viewModel.details.category = $0?.first
            }
        }
    }()

    private lazy var odometerItem: BaseFormItem = {
        let title = NSLocalizedString("Odometer", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .width(.column(3))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Odometer must be a number")
            .text(viewModel.details.odometer)
            .onValueChanged { [weak self] in
                self?.viewModel.details.odometer = $0
        }
    }()

    private lazy var equipmentItem: BaseFormItem = {
        let title = NSLocalizedString("Equipment", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .width(.column(1))
            .text(viewModel.details.equipment)
            .onValueChanged { [weak self] in
                self?.viewModel.details.equipment = $0
        }
    }()

    private lazy var remarksItem: BaseFormItem = {
        let title = NSLocalizedString("Remarks", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .width(.column(1))
            .softValidate(CountSpecification.max(1000), message: "Must be no more than 1000 characters")
            .text(viewModel.details.remarks)
            .onValueChanged { [weak self] in
                self?.viewModel.details.remarks = $0
        }
    }()

    /// Start time of shift
    private lazy var startTimeItem: BaseFormItem = {
        // Set default start time to next hour if not set
        viewModel.details.startTime = viewModel.details.startTime ?? Date().rounded(minutes: 60, rounding: .ceil)

        let title = NSLocalizedString("Start Time", comment: "")
        if self.viewModel.isEditing {
            let value = DateFormatter.formTime.string(from: viewModel.details.startTime!)
            return ValueFormItem(title: title, value: value)
                .width(.column(3))
        } else {
            return DateFormItem(title: title)
                .width(.column(3))
                .required()
                .datePickerMode(.dateAndTime)
                .dateFormatter(.formTime)
                .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
                .minuteInterval(15)
                .selectedValue(viewModel.details.startTime)
                .onValueChanged { [weak self] in
                    self?.viewModel.details.startTime = $0
                    self?.updateDuration()
            }
        }
    }()

    /// End time of shift
    private lazy var endTimeItem: DateFormItem = {
        // Set default end time to start time plus 8 hours if not set
        viewModel.details.endTime = viewModel.details.endTime ?? Date().rounded(minutes: 60, rounding: .ceil).adding(hours: 8)

        let title = NSLocalizedString("Est. End Time", comment: "")
        return DateFormItem(title: title)
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(viewModel.details.endTime)
            .onValueChanged { [weak self] in
                self?.viewModel.details.endTime = $0
                self?.updateDuration()
        }
    }()

    /// Calculated duration of shift
    private lazy var durationItem: ValueFormItem = {
        return ValueFormItem(title: NSLocalizedString("Duration", comment: ""), value: "")
            .width(.column(3))
    }()

    /// Construct the form
    override open func construct(builder: FormBuilder) {

        // Show list of officers first, followed by shift details then optional sections

        let officersTitleFormat = NSLocalizedString("%d Officer(s)", comment: "") as NSString
        let officersTitle = NSString.localizedStringWithFormat(officersTitleFormat, viewModel.details.officers.count) as String

        builder += HeaderFormItem(text: officersTitle.uppercased(), style: .plain)
            .actionButton(title: NSLocalizedString("Add", comment: "").uppercased(), handler: { [unowned self] in
                let viewController = self.viewModel.officerSearchViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            })

        // Button to delete officer (only available for additional officers)
        let deleteAction = CollectionViewFormEditAction(title: "Delete", color: .red, handler: { [unowned self] (cell, indexPath) in
            self.viewModel.removeOfficer(at: indexPath.row)
            self.reloadForm()
        })

        let incompleteColor = #colorLiteral(red: 0.9843137255, green: 0.3137254902, blue: 0.2980392157, alpha: 1)
        for (index, officer) in viewModel.details.officers.enumerated() {
            let accessoryLabel = AccessoryTextStyle.roundedRect(AccessoryLabelDetail(text: officer.incompleteStatus, textColour: incompleteColor, borderColour: incompleteColor))
            builder += BookOnDetailsOfficerFormItem(title: officer.title,
                                                    subtitle: officer.subtitle,
                                                    status: officer.driverStatus)
                .width(.column(1))
                .height(.fixed(60))
                .accessory(FormAccessoryView(style: .disclosure, labelStyle: accessoryLabel))
                .editActions([index > 0 ? deleteAction : nil].removeNils())
                .onSelection { [unowned self] cell in
                    let viewController = self.viewModel.officerDetailsViewController(at: index)
                    self.navigationController?.pushViewController(viewController, animated: true)
            }
        }

        builder += HeaderFormItem(text: NSLocalizedString("Shift Details", comment: "").uppercased(), style: .plain)
        builder += startTimeItem
        builder += endTimeItem
        builder += durationItem

        if viewModel.showVehicleFields {
            builder += HeaderFormItem(text: NSLocalizedString("Vehicle Details", comment: "").uppercased(), style: .plain)
            builder += serialItem
            builder += categoryItem
            builder += odometerItem
            builder += equipmentItem
            builder += remarksItem
        }

        updateDuration()
    }

    // MARK: - Internal

    /// Date formatter for duration field
    private var durationDateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()

    private func updateDuration() {
        // Update the generated duration field
        if let startTime = viewModel.details.startTime, var endTime = viewModel.details.endTime {
            if endTime < startTime {
                // If endtime is before start time, clip it and reload the cell
                endTime = startTime
                endTimeItem.minimumDate = startTime
                endTimeItem.selectedValue = startTime
                endTimeItem.reloadItem()
            } else {
                endTimeItem.minimumDate = startTime
            }
            // Format duration as abbreviated string, eg "1h 15m"
            durationItem.value = durationDateFormatter.string(from: endTime.timeIntervalSince(startTime))
        } else {
            durationItem.value = ""
        }
        durationItem.reloadItem()
    }

    @objc private func cancelFormTapped() {
        closeForm()
    }

    @objc private func submitFormTapped() {
        let result = builder.validate()

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            // Check officer forms are also valid
            for officer in viewModel.details.officers {
                if officer.incompleteStatus != nil {
                    AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Please complete details for officers", comment: ""))
                    return
                }
            }
            self.submitForm()
        }
    }

    private func submitForm() {
        // TODO: show progress overlay
        firstly {
            return viewModel.submitForm()
            }.then { [unowned self] status in
                self.closeForm()
            }.always {
                // TODO: Cancel progress overlay
            }.catch { error in
                let title = NSLocalizedString("Failed to submit form", comment: "")
                AlertQueue.shared.addSimpleAlert(title: title, message: error.localizedDescription)
        }
    }

    private func closeForm() {
        if viewModel.isEditing {
            _ = navigationController?.popViewController(animated: true)
        } else {
            if presentingViewController != nil {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            } 
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        // Allow shrinking of generated duration value to fit cell, eg "2 days, 5 hr, 30 min"
        if let cell = cell as? CollectionViewFormValueFieldCell, cell == durationItem.cell {
            cell.valueLabel.adjustsFontSizeToFitWidth = true
        }
    }
}

extension BookOnDetailsFormViewController: BookOnDetailsFormViewModelDelegate {
    public func didUpdateDetails() {
        navigationController?.popToViewController(self, animated: true)
        reloadForm()
    }
}
