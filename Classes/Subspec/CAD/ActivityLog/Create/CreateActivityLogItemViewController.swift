//
//  CreateActivityLogItemViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class CreateActivityLogItemViewController: IntrinsicHeightFormBuilderViewController {

    // MARK: - Properties

    /// View model of the view controller
    open let viewModel: CreateActivityLogItemViewModel

    public init(viewModel: CreateActivityLogItemViewModel) {
        self.viewModel = viewModel
        super.init()
        setupNavigationBarButtons()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
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

        builder += HeaderFormItem(text: NSLocalizedString("Details", comment: "").uppercased(), style: .plain)

        builder += DropDownFormItem(title: NSLocalizedString("Activity type", comment: ""))
            .width(.column(2))
            .required("Activity type is required.")
            .options(viewModel.activityTypeOptions)
            .selectedValue([viewModel.activityType].removeNils())
            .onValueChanged({ [unowned self] in
                self.viewModel.activityType = $0?.first
            })

        builder += DropDownFormItem(title: NSLocalizedString("Event reference", comment: ""))
            .width(.column(2))
            .options(viewModel.eventReferenceOptions)
            .selectedValue([viewModel.eventReference].removeNils())
            .onValueChanged({ [unowned self] in
                self.viewModel.eventReference = $0?.first
            })

        builder += DateFormItem(title: NSLocalizedString("Start Time", comment: ""))
            .width(.column(2))
            .required("Start time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minuteInterval(5)
            .selectedValue(viewModel.startTime ?? Date().rounded(minutes: 15, rounding: .floor))
            .onValueChanged({ [unowned self] in
                self.viewModel.startTime = $0
            })

        builder += DateFormItem(title: NSLocalizedString("End Time", comment: ""))
            .width(.column(2))
            .required("End time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minuteInterval(5)
            .selectedValue(viewModel.endTime)
            .onValueChanged({ [unowned self] in
                self.viewModel.endTime = $0
            })

        builder += TextFieldFormItem(title: NSLocalizedString("Remarks", comment: ""))
            .width(.column(1))
            .text(viewModel.remarks)
            .placeholder("Required")
            .required("Remark is required")
            .onValueChanged({ [unowned self] in
                self.viewModel.remarks = $0
            })

        if let officerList = viewModel.officerList() {
            builder += HeaderFormItem(text: NSLocalizedString("Officers Involved", comment: "").uppercased(), style: .plain)
            for officer in officerList {
                builder += OptionFormItem(title: officer)
                    .width(.column(1))
                    .separatorStyle(.none)
            }
        }
    }


    @objc private func cancelButtonTapped(_ button: UIBarButtonItem) {
        viewModel.cancel()
    }

    @objc private func doneButtonTapped(_ button: UIBarButtonItem) {
        let result = builder.validate()

        switch result {
        case .invalid(_, let message):
            builder.validateAndUpdateUI()
            AlertQueue.shared.addErrorAlert(message: message)
        case .valid:
            viewModel.submit()
        }
    }
}
