//
//  DomesticViolenceGeneralDetailsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

open class DomesticViolenceGeneralDetailsViewController: FormBuilderViewController, EvaluationObserverable {

    private(set) var viewModel: DomesticViolenceGeneralDetailsViewModel

    public init(viewModel: DomesticViolenceGeneralDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.addObserver(self)

        title = "General Details"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title

        builder += LargeTextHeaderFormItem(text: "Details")
            .separatorColor(.clear)

        builder += StepperFormItem(title: "Number of Children in this Relationship")
                    .maximumValue(99.0)
                    .value(Double(viewModel.report.childCount))
                    .onValueChanged({ value in
                        self.viewModel.report.childCount = Int(value)
                    })

        builder += OptionFormItem(title: "Child/Children to be Named")
                    .width(.column(2))
                    .isChecked(viewModel.report.childrenToBeNamed)
                    .onValueChanged({ value in
                        self.viewModel.report.childrenToBeNamed = value
                    })

        builder += OptionFormItem(title: "Relative/Associate to be Named")
                    .width(.column(2))
                    .isChecked(viewModel.report.associateToBeNamed)
                    .onValueChanged({ value in
                        self.viewModel.report.associateToBeNamed = value
                    })

        builder += TextFieldFormItem(title: "Grounds on Which Domestic Violence has been Committed")
                    .text(viewModel.report.details)
                    .onValueChanged({ text in
                        self.viewModel.report.details = text
                    })

        builder += TextViewFormItem(title: "Remarks")
                    .text(viewModel.report.remarks)
                    .onValueChanged({ text in
                        self.viewModel.report.remarks = text
                    })
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
