//
//  BookOnDetailsFormViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class BookOnDetailsFormViewController: FormBuilderViewController {

    /// Less transparent background to default when used in form sheet, to give contrast for form text
    private var transparentBackground = UIColor(white: 1, alpha: 0.5)

    private var viewModel: BookOnDetailsFormViewModel

    private var details = BookOnDetails()

    private var startTimeItem: DateFormItem!
    private var endTimeItem: DateFormItem!
    private var durationItem: ValueFormItem!

    public init(viewModel: BookOnDetailsFormViewModel) {
        self.viewModel = viewModel
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelFormTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitFormTapped))
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override open var wantsTransparentBackground: Bool {
        didSet {
            if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
                view?.backgroundColor = transparentBackground
            }
        }
    }

    override func apply(_ theme: Theme) {
        super.apply(theme)

        if wantsTransparentBackground && ThemeManager.shared.currentInterfaceStyle == .light {
            view?.backgroundColor = transparentBackground
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
        }, completion: nil)
    }

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

    override func construct(builder: FormBuilder) {

        builder += HeaderFormItem(text: "VEHICLE DETAILS", style: .plain)

        builder += TextFieldFormItem(title: "Serial", text: nil)
            .width(.column(3))
            .required("Serial is required.")
            .onValueChanged { [unowned self] in
                self.details.serial = $0
        }

        builder += DropDownFormItem(title: "Category")
            .options(["1", "2", "3"])
            .required()
            .width(.column(3))
            .onValueChanged { [unowned self] in
                self.details.category = $0?.first
        }

        builder += TextFieldFormItem(title: "Odometer", text: nil)
            .width(.column(3))
            .strictValidate(CharacterSetSpecification.decimalDigits, message: "Odometer must be a number")
            .onValueChanged { [unowned self] in
                self.details.odometer = $0
        }

        builder += TextFieldFormItem(title: "Remarks", text: nil)
            .width(.column(1))
            .onValueChanged { [unowned self] in
                self.details.remarks = $0
        }

        builder += HeaderFormItem(text: "SHIFT DETAILS", style: .plain)


        startTimeItem = DateFormItem(title: "Start Time")
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date())
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil))
            .onValueChanged { [unowned self] in
                self.details.startTime = $0
                self.updateDuration()
        }

        endTimeItem = DateFormItem(title: "Est. End Time")
            .width(.column(3))
            .required()
            .datePickerMode(.dateAndTime)
            .dateFormatter(.formTime)
            .minimumDate(Date())
            .selectedValue(Date().rounded(minutes: 60, rounding: .ceil).adding(hours: 8))
            .onValueChanged { [unowned self] in
                self.details.endTime = $0
                self.updateDuration()
        }

        durationItem = ValueFormItem(title: "Duration", value: "")
            .width(.column(3))

        builder += startTimeItem
        builder += endTimeItem
        builder += durationItem
        updateDuration()
    }

    @objc private func cancelFormTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func submitFormTapped() {
        let result = builder.validate()

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        case .valid:
            dismiss(animated: true, completion: nil)
        }
    }

}

class BookOnDetails {
    var serial: String?
    var category: String?
    var odometer: String?
    var remarks: String?
    var startTime: Date?
    var endTime: Date?
    var duration: String?
}

