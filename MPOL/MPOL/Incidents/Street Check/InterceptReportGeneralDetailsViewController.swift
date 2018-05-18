//
//  InterceptReportGeneralDetailsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

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

        viewModel.report.viewed = true
        reloadForm()
        loadingManager.state = viewModel.loadingManagerState
    }


    override public func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true
        builder += HeaderFormItem(text: viewModel.headerFormItemTitle)
    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
