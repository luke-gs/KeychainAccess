//
//  EventDateTimeViewController.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The OOTB DateTime viewController
open class DefaultEventDateTimeViewController: FormBuilderViewController, EvaluationObserverable {

    var viewModel: DefaultDateTimeViewModel

    public init(viewModel: DefaultDateTimeViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.report.evaluator.addObserver(self)
        
        sidebarItem.regularTitle = "Date and Time"
        sidebarItem.compactTitle = "Date and Time"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.date)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {

        // pre-declare formItems to allow other form items access to them
        let reportedOn = DateFormItem()
        let startTime = DateFormItem()
        let endTime = DateFormItem()

        builder += LargeTextHeaderFormItem(text: "Reported On")
            .separatorColor(.clear)

        // reportedOn datePicker
        reportedOn.title("Date and Time")
            .selectedValue(viewModel.report?.reportedOnDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .maximumDate(Date())
            .selectedValue(viewModel.report?.reportedOnDateTime)
            .onValueChanged({ [viewModel] date in
                viewModel.reportedOnDateTimeChanged(date)
                startTime.maximumDate(date)
            })
            .required()
        builder += reportedOn

        builder +=  LargeTextHeaderFormItem(text: "Took Place From")
            .separatorColor(.clear)

        // startTime datePicker
        startTime.title("Start Time")
            .selectedValue(viewModel.report?.tookPlaceFromStartDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .maximumDate(viewModel.report?.reportedOnDateTime)
            .selectedValue(viewModel.report?.tookPlaceFromStartDateTime)
            .onValueChanged { [viewModel] date in
                viewModel.adjustEndTime(for: date, in: endTime)
                viewModel.tookPlaceFromStartDateTimeChanged(date)
            }
            .required()
        builder += startTime

        // endTime datePicker
        endTime.title("End Time")
            .selectedValue(viewModel.report?.tookPlaceFromEndDateTime)
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .elementIdentifier("tookPlaceFromEndDateTime")
            .minimumDate(Date())
            .onValueChanged(viewModel.tookPlaceFromEndDateTimeChanged)
         builder += endTime

    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

}
