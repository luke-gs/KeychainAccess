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

    // Form items we need to keep reference to
    private var startTimeItem: DateFormItem!
    private var endTimeItem: DateFormItem!
    private var durationItem: ValueFormItem!

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

    override open func construct(builder: FormBuilder) {

        builder += HeaderFormItem(text: NSLocalizedString("VEHICLE DETAILS", comment: ""), style: .plain)

        builder += TextFieldFormItem(title: NSLocalizedString("Serial", comment: ""), text: nil)
            .width(.column(3))
            .required("Serial is required.")
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Serial must be a number")
            .onValueChanged { [unowned self] in
                self.viewModel.details.serial = $0
        }

        builder += DropDownFormItem(title: NSLocalizedString("Category", comment: ""))
            .options(["1", "2", "3"])
            .required()
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.viewModel.details.category = $0?.first
        }

        builder += TextFieldFormItem(title: NSLocalizedString("Odometer", comment: ""), text: nil)
            .width(.column(3))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Odometer must be a number")
            .onValueChanged { [unowned self] in
                self.viewModel.details.odometer = $0
        }

        builder += TextFieldFormItem(title: NSLocalizedString("Equipment", comment: ""), text: nil)
            .width(.column(1))
            .onValueChanged { [unowned self] in
                self.viewModel.details.equipment = $0
        }

        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""), text: nil)
            .width(.column(1))
            .softValidate(CountSpecification.max(1000), message: "Must be no more than 1000 characters")
            .onValueChanged { [unowned self] in
                self.viewModel.details.remarks = $0
        }

        builder += HeaderFormItem(text: NSLocalizedString("SHIFT DETAILS", comment: ""), style: .plain)


        startTimeItem = DateFormItem(title: NSLocalizedString("Start Time", comment: ""))
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil))
            .onValueChanged { [unowned self] in
                self.viewModel.details.startTime = $0
                self.updateDuration()
        }

        endTimeItem = DateFormItem(title: NSLocalizedString("Est. End Time", comment: ""))
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date().rounded(minutes: 15, rounding: .ceil))
            .minuteInterval(15)
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil).adding(hours: 8))
            .onValueChanged { [unowned self] in
                self.viewModel.details.endTime = $0
                self.updateDuration()
        }

        durationItem = ValueFormItem(title: NSLocalizedString("Duration", comment: ""), value: "")
            .width(.column(3))

        builder += startTimeItem
        builder += endTimeItem
        builder += durationItem
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
