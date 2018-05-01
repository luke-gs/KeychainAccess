//
//  TrafficInfringementServiceViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}
open class TrafficInfringementServiceViewController: FormBuilderViewController, EvaluationObserverable {

    weak var report: TrafficInfringementServiceReport?

    public init(report: Reportable?) {
        self.report = report as? TrafficInfringementServiceReport
        super.init()
        report?.evaluator.addObserver(self)

        title = "Service"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.service)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red

        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "Service requires a person or organisation"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)

        loadingManager.state = .noContent
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report?.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "GENERAL")
        builder += HeaderFormItem(text: "SUMMARY / NOTES")
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
