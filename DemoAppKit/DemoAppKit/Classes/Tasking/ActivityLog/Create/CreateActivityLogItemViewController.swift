//
//  CreateActivityLogItemViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 30/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import CoreKit

open class CreateActivityLogItemViewController: SubmissionFormBuilderViewController {

    // MARK: - Properties

    /// View model of the view controller
    public let viewModel: CreateActivityLogItemViewModel

    public init(viewModel: CreateActivityLogItemViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
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

        let startTimeItem = DateFormItem(title: NSLocalizedString("Start Time", comment: ""))
            .width(.column(2))
            .required("Start time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minuteInterval(5)
            .selectedValue(viewModel.startTime)

        let endTimeItem = DateFormItem(title: NSLocalizedString("End Time", comment: ""))
            .minimumDate(viewModel.startTime)
            .width(.column(2))
            .required("End time is required.")
            .datePickerMode(.dateAndTime)
            .dateFormatter(.relativeShortDateAndTimeFullYear)
            .minuteInterval(5)
            .selectedValue(viewModel.endTime)
            .submitValidate(PredicateSpecification<Date>(predicate: { [unowned self] (date) -> Bool in
                guard let startTime = self.viewModel.startTime else { return true }
                return date > startTime
            }), message: "End time must be after start time.")

        startTimeItem.onValueChanged({ [unowned self] in
            self.viewModel.startTime = $0
            endTimeItem.minimumDate(self.viewModel.startTime)
            endTimeItem.reloadSubmitValidationState()
        })

        endTimeItem.onValueChanged({ [unowned self] in
            self.viewModel.endTime = $0
        })


        builder += startTimeItem
        builder += endTimeItem

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

    // MARK: - SubmissionFormBuilderViewController

    /// Perform actual submit logic
    open override func performSubmit() -> Promise<Void> {
        return viewModel.submit()
    }
}
