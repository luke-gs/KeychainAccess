//
//  InterceptReportGeneralDetailsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

public class InterceptReportGeneralDetailsViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: InterceptReportGeneralDetailsViewModel

    public required convenience init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: InterceptReportGeneralDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        self.viewModel.report.evaluator.addObserver(self)

        title = "Details"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadForm()
        loadingManager.state = .loaded
    }


    override public func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = false
        builder += LargeTextHeaderFormItem(text: viewModel.headerFormItemTitle)
            .separatorColor(.clear)

        builder += DropDownFormItem(title: "Subject")
            .required()
            .options(viewModel.subjectOptions)
            .selectedValue([viewModel.report.selectedSubject ?? ""])
            .width(.column(2))
            .onValueChanged({ (value) in
                guard let value = value?.first else { return }
                self.viewModel.report.selectedSubject = value
            })

        builder += DropDownFormItem(title: "Secondary Subject")
            .required()
            .options(viewModel.secondarySubjectOptions)
            .selectedValue([viewModel.report.selectedSecondarySubject ?? ""])
            .width(.column(2))
            .onValueChanged({ (value) in
                guard let value = value?.first else { return }
                self.viewModel.report.selectedSecondarySubject = value
            })

        builder += TextViewFormItem(title: "Remarks")
            .text(viewModel.report.remarks ?? "")
            .onValueChanged({ (value) in
                guard let value = value else { return }
                self.viewModel.report.remarks = value
            })
    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
