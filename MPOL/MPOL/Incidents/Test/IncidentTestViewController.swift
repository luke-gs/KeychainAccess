//
//  IncidentTestViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}
// TODO: REMOVE THIS CLASS WHEN START INCIDENTS
open class IncidentTestViewController: FormBuilderViewController, EvaluationObserverable {

    weak var report: IncidentTestReport?

    public init(report: Reportable?) {
        self.report = report as? IncidentTestReport
        super.init()
        report?.evaluator.addObserver(self)

        sidebarItem.regularTitle = "Amazing Incidents"
        sidebarItem.compactTitle = "Amazing Incidents"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report?.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Test Test Test"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "GENERAL")
        builder += HeaderFormItem(text: "SUMMARY / NOTES")
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
