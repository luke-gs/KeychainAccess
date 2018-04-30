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

    open var buttonsView: DialogActionButtonsView?

    // MARK: - Initializers

    public init(viewModel: BookOnDetailsFormViewModel) {
        self.viewModel = viewModel
        super.init()

        createButtonViewIfNecessary()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelFormTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(submitFormTapped))
    }

    open func createButtonViewIfNecessary() {
        // Only show if editing current book on
        guard viewModel.isEditing else { return }

        let buttonsView = DialogActionButtonsView(actions: [
            DialogAction(title: viewModel.terminateButtonText(), handler: { [weak self] (action) in
                self?.terminateShift()
            })
        ])
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        self.buttonsView = buttonsView

        collectionView?.translatesAutoresizingMaskIntoConstraints = false

        // Make space for button view and position it below form
        if let collectionView = collectionView {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor, constant: -DialogActionButtonsView.LayoutConstants.defaultHeight).withPriority(.almostRequired),

                buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
            ])
        }
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
        let title = NSLocalizedString("Fleet ID", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .autocapitalizationType(.allCharacters)
            .width(.column(2))
            .required("Fleet ID is required.")
            .strictValidate(CharacterSetSpecification.alphanumerics, message: "Fleet ID must only use numbers and letters")
            .text(viewModel.content.serial)
            .onValueChanged { [weak self] in
                self?.viewModel.content.serial = $0
        }
    }()

    private lazy var categoryItem: BaseFormItem = {
        let title = NSLocalizedString("Category", comment: "")
        return DropDownFormItem(title: title)
            // TODO: get these from manifest
            .options(["1. Marked Intercept Sedan or Motorcycle",
                      "2. Intercept unmarked Sedan or Motorcycle",
                      "3. Marked Intercept Van, 4WD",
                      "4. Unmarked non-intercept vehicle"])
            .required("Category is required.")
            .width(.column(1))
            .selectedValue([viewModel.content.category].removeNils())
            .onValueChanged { [weak self] in
                self?.viewModel.content.category = $0?.first
        }
    }()

    private lazy var odometerItem: BaseFormItem = {
        let title = NSLocalizedString("Odometer", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .width(.column(2))
            .keyboardType(.numberPad)
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Odometer must be a number")
            .text(viewModel.content.odometer)
            .onValueChanged { [weak self] in
                self?.viewModel.content.odometer = $0
        }
    }()

    private lazy var equipmentItem: BaseFormItem = {
        let viewModel = QuantityPickerViewModel(items: self.viewModel.content.equipment, subjectMatter: NSLocalizedString("Equipment", comment: ""))
        let title = NSLocalizedString("Equipment", comment: "")
        return QuantityPickerFormItem(viewModel: viewModel, title: title)
            .width(.column(1))
            .pickerTitle(NSLocalizedString("Add Equipment", comment: ""))
            .onValueChanged { [weak self] in
                self?.viewModel.content.equipment = $0 ?? []
        }
    }()

    private lazy var remarksItem: BaseFormItem = {
        let title = NSLocalizedString("Remarks", comment: "")
        return TextFieldFormItem(title: title, text: nil)
            .width(.column(1))
            .softValidate(CountSpecification.max(1000), message: "Must be no more than 1000 characters")
            .text(viewModel.content.remarks)
            .onValueChanged { [weak self] in
                self?.viewModel.content.remarks = $0
        }
    }()

    /// Start time of shift
    private lazy var startTimeItem: BaseFormItem = {
        // Set default start time to next hour if not set
        viewModel.content.startTime = viewModel.content.startTime ?? Date().rounded(minutes: 60, rounding: .ceil)

        let title = NSLocalizedString("Start Time", comment: "")
        return DateFormItem(title: title)
            .width(.column(2))
            .required("Start time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(viewModel.content.startTime)
            .onValueChanged { [weak self] in
                self?.viewModel.content.startTime = $0
                self?.updateDuration()
        }
    }()

    /// End time of shift
    private lazy var endTimeItem: DateFormItem = {
        // Set default end time to start time plus 8 hours if not set
        viewModel.content.endTime = viewModel.content.endTime ?? Date().rounded(minutes: 60, rounding: .ceil).adding(hours: 8)

        let title = NSLocalizedString("Est. End Time", comment: "")
        return DateFormItem(title: title)
            .width(.column(2))
            .required("End time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(viewModel.content.endTime)
            .onValueChanged { [weak self] in
                self?.viewModel.content.endTime = $0
                self?.updateDuration()
        }
    }()

    /// Calculated duration of shift
    private lazy var durationItem: ValueFormItem = {
        return ValueFormItem(title: NSLocalizedString("Duration", comment: ""), value: "")
            .width(.column(1))
    }()

    /// Construct the form
    override open func construct(builder: FormBuilder) {

        // Show list of officers first, followed by shift details then optional sections

        let officersTitleFormat = NSLocalizedString("%d Officer(s)", comment: "")
        let officersTitle = String.localizedStringWithFormat(officersTitleFormat, viewModel.content.officers.count)

        builder += HeaderFormItem(text: officersTitle.uppercased(), style: .plain)
            .actionButton(title: NSLocalizedString("Add", comment: "").uppercased(), handler: { [unowned self] _ in
                let screen = self.viewModel.officerSearchScreen()
                self.present(screen)
            })

        // Button to delete officer and reload form
        let deleteAction = CollectionViewFormEditAction(title: "Delete", color: .orangeRed, handler: { [unowned self] (cell, indexPath) in
            self.viewModel.removeOfficer(at: indexPath.row)
            self.reloadForm()
        })

        for (index, officer) in viewModel.content.officers.enumerated() {
            let editActions = viewModel.allowRemoveOfficer(at: index) ? [deleteAction] : []
            builder += BookOnDetailsOfficerFormItem(title: officer.title,
                                                    subtitle: officer.subtitle,
                                                    status: officer.driverStatus,
                                                    image: officer.thumbnail())
                .width(.column(1))
                .height(.fixed(60))
                .accessory(FormAccessoryView(style: .pencil))
                .editActions(editActions)
                .onSelection { [unowned self] cell in
                    let screen = self.viewModel.officerDetailsScreen(at: index)
                    self.present(screen)
            }
        }

        builder += HeaderFormItem(text: NSLocalizedString("Shift Details", comment: "").uppercased(), style: .plain)
        builder += startTimeItem
        builder += endTimeItem
        builder += durationItem

        if viewModel.showVehicleFields {
            builder += HeaderFormItem(text: NSLocalizedString("Vehicle Details", comment: "").uppercased(), style: .plain)
            builder += serialItem
            builder += odometerItem
            builder += categoryItem
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
        if let startTime = viewModel.content.startTime, var endTime = viewModel.content.endTime {
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
        if loadingManager.state == .error {
            loadingManager.state = .loaded
            navigationItem.rightBarButtonItem?.isEnabled = true
            buttonsView?.alpha = 1
        } else {
            closeForm(submitted: false)
        }
    }

    @objc private func submitFormTapped() {
        #if DEBUG
            // Skip validation when debug, to keep devs happy
            self.submitForm()
            if view != nil { return }
        #endif

        let result = builder.validate()

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            // Check officer forms are also valid
            for officer in viewModel.content.officers {
                if officer.inComplete {
                    AlertQueue.shared.addErrorAlert(message: NSLocalizedString("Please complete details for officers", comment: ""))
                    return
                }
            }
            self.submitForm()
        }
    }

    @objc private func terminateShift() {
        // Show progress overlay
        loadingManager.state = .loading
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        buttonsView?.alpha = 0

        firstly {
            return viewModel.terminateShift()
        }.done { [weak self] status in
            self?.closeForm(submitted: false)
        }.catch { [weak self] error in
            // Update progress overlay to show error
            self?.loadingManager.state = .error
            self?.navigationItem.leftBarButtonItem?.isEnabled = true
            self?.navigationItem.rightBarButtonItem?.isEnabled = false

            self?.loadingManager.errorView.titleLabel.text = "Unable to Terminate Shift"
            self?.loadingManager.errorView.subtitleLabel.text = error.localizedDescription
            self?.loadingManager.errorView.actionButton.setTitle("Try Again", for: .normal)
            self?.loadingManager.errorView.actionButton.addTarget(self, action: #selector(self?.terminateShift), for: .touchUpInside)
        }
    }

    @objc private func submitForm() {
        // Show progress overlay
        loadingManager.state = .loading
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        buttonsView?.alpha = 0

        firstly {
            return viewModel.submitForm()
        }.done { [weak self] status in
            self?.closeForm(submitted: true)
        }.catch { [weak self] error in
            // Update progress overlay to show error
            self?.loadingManager.state = .error
            self?.navigationItem.leftBarButtonItem?.isEnabled = true
            self?.navigationItem.rightBarButtonItem?.isEnabled = false

            // TODO: Provide actual error to the user?
            self?.loadingManager.errorView.subtitleLabel.text = NSLocalizedString("There was an error while attempting to Book On", comment: "")

            self?.loadingManager.errorView.actionButton.setTitle("Try Again", for: .normal)
            self?.loadingManager.errorView.actionButton.addTarget(self, action: #selector(self?.submitForm), for: .touchUpInside)
        }
    }

    private func closeForm(submitted: Bool) {
        // If pushed view, dismiss the modal if we are booking on and got presented, go back to previous screen otherwise
        if navigationController?.viewControllers.count ?? 0 > 1 {
            if submitted && !viewModel.isEditing && presentingViewController != nil {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            // Not pushed, so dismiss
            if presentingViewController != nil {
                dismiss(animated: true, completion: nil)
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
