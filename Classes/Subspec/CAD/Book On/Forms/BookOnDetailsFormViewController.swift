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

    override open func viewDidLoad() {
        super.viewDidLoad()
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
        }, completion: nil)
    }

    // MARK: - Form

    private lazy var serialItem: TextFieldFormItem = {
        return TextFieldFormItem(title: NSLocalizedString("Serial", comment: ""), text: nil)
            .width(.column(3))
            .required("Serial is required.")
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Serial must be a number")
            .onValueChanged { [weak self] in
                self?.viewModel.details.serial = $0
        }
    }()

    private lazy var categoryItem: DropDownFormItem = {
        return DropDownFormItem(title: NSLocalizedString("Category", comment: ""))
            .options(["1", "2", "3"])
            .required()
            .width(.column(3))
            .onValueChanged { [weak self] in
                self?.viewModel.details.category = $0?.first
        }
    }()

    private lazy var odometerItem: TextFieldFormItem = {
        return TextFieldFormItem(title: NSLocalizedString("Odometer", comment: ""), text: nil)
            .width(.column(3))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Odometer must be a number")
            .onValueChanged { [weak self] in
                self?.viewModel.details.odometer = $0
        }
    }()

    private lazy var equipmentItem: TextFieldFormItem = {
        return TextFieldFormItem(title: NSLocalizedString("Equipment", comment: ""), text: nil)
            .width(.column(1))
            .onValueChanged { [weak self] in
                self?.viewModel.details.equipment = $0
        }
    }()

    private lazy var remarksItem: TextFieldFormItem = {
        return TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""), text: nil)
            .width(.column(1))
            .softValidate(CountSpecification.max(1000), message: "Must be no more than 1000 characters")
            .onValueChanged { [weak self] in
                self?.viewModel.details.remarks = $0
        }
    }()

    /// Start time of shift
    private lazy var startTimeItem: DateFormItem = {
        return DateFormItem(title: NSLocalizedString("Start Time", comment: ""))
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil))
            .onValueChanged { [weak self] in
                self?.viewModel.details.startTime = $0
                self?.updateDuration()
        }
    }()

    /// End time of shift
    private lazy var endTimeItem: DateFormItem = {
        return DateFormItem(title: NSLocalizedString("Est. End Time", comment: ""))
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil).adding(hours: 8))
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

        builder += HeaderFormItem(text: NSLocalizedString("Vehicle Details", comment: "").uppercased(), style: .plain)
        builder += serialItem
        builder += categoryItem
        builder += odometerItem
        builder += equipmentItem
        builder += remarksItem

        builder += HeaderFormItem(text: NSLocalizedString("Shift Details", comment: "").uppercased(), style: .plain)
        builder += startTimeItem
        builder += endTimeItem
        builder += durationItem

        builder += HeaderFormItem(text: NSLocalizedString("Officers", comment: "").uppercased(), style: .plain)
        for officer in viewModel.details.officers {
            builder += SubtitleFormItem(title: officer.title,
                                        subtitle: officer.subtitle,
                                        image: nil,
                                        style: .default)
                .width(.column(1))
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(60))
                .onSelection { [unowned self] cell in
                    self.navigationController?.pushViewController(self.viewModel.officerDetailsViewController(), animated: true)
            }
        }

        updateDuration()
    }

    // MARK: - Internal

    private func updateDuration() {
        // Update the generated duration field
        if let startTime = startTimeItem.selectedValue, var endTime = endTimeItem.selectedValue {
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
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated

            durationItem.value = formatter.string(from: endTime.timeIntervalSince(startTime))
        } else {
            durationItem.value = ""
        }
        durationItem.reloadItem()
    }

    @objc private func cancelFormTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func submitFormTapped() {
        let result = builder.validate()

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            firstly {
                return viewModel.submitForm()
            }.then { status in
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                let title = NSLocalizedString("Failed to submit form", comment: "")
                AlertQueue.shared.addSimpleAlert(title: title, message: error.localizedDescription)
            }
        }
    }

    // MARK: - Background

    /// Less transparent background to default when used in form sheet, to give contrast for form text
    private var transparentBackground = UIColor(white: 1, alpha: 0.5)

    override open var wantsTransparentBackground: Bool {
        didSet {
            if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
                view?.backgroundColor = transparentBackground
            }
        }
    }

    override open func apply(_ theme: Theme) {
        super.apply(theme)
        if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
            view?.backgroundColor = transparentBackground
        }
    }
}
