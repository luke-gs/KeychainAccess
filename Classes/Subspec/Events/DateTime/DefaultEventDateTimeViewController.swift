//
//  EventDateTimeViewController.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

internal extension EvaluatorKey {
    static let reportedOnDateTime = EvaluatorKey(rawValue: "reportedOnDateTime")
    static let tookPlaceFromStartDateTime = EvaluatorKey(rawValue: "tookPlaceFromStartDateTime")
}

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
        sidebarItem.color = viewModel.tabColour()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "REPORTED ON")

        builder += DateFormItem()
            .title("Report Time")
            .selectedValue(viewModel.report?.reportedOnDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .maximumDate(Date())
            .selectedValue(viewModel.report?.reportedOnDateTime)
            .onValueChanged(viewModel.reportedOnDateTimeChanged)
            .required()

        builder += HeaderFormItem(text: "TOOK PLACE FROM")

        builder += DateFormItem()
            .title("Start")
            .selectedValue(viewModel.report?.tookPlaceFromStartDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .selectedValue(viewModel.report?.tookPlaceFromStartDateTime)
            .onValueChanged { [viewModel] date in
                guard let formItem = self.builder.formItem(for: "tookPlaceFromEndDateTime") as? DateFormItem else { return }
                viewModel.adjustEndTime(for: date, in: formItem)
                viewModel.tookPlaceFromStartDateTimeChanged(date)
            }
            .required()

        builder +=  DateFormItem()
            .title("End")
            .selectedValue(viewModel.report?.tookPlaceFromEndDateTime)
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .elementIdentifier("tookPlaceFromEndDateTime")
            .minimumDate(Date())
            .onValueChanged(viewModel.tookPlaceFromEndDateTimeChanged)
        
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }

}
