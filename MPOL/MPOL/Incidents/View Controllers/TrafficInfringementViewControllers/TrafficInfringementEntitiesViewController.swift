//
//  TrafficInfringementEntitiesViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}
open class TrafficInfringementEntitiesViewController: FormBuilderViewController, EvaluationObserverable {

    weak var report: TrafficInfringementEntitiesReport?

    public init(report: Reportable?) {
        self.report = report as? TrafficInfringementEntitiesReport
        super.init()
        report?.evaluator.addObserver(self)

        title = "Entities"

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
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
        builder.title = title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "GENERAL")
        builder += HeaderFormItem(text: "SUMMARY / NOTES")
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
