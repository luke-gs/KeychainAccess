//
//  PersonSearchReportViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class PersonSearchReportViewController: FormBuilderViewController, EvaluationObserverable {

    public let viewModel: PersonSearchReportViewModel

    public init(viewModel: PersonSearchReportViewModel) {
        self.viewModel = viewModel
        super.init()
        self.title = "Person Search Report"
        wantsTransparentBackground = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSelected))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneSelected))
        viewModel.report.evaluator.addObserver(self)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report.viewed = true
    }

    @objc func cancelSelected(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func doneSelected(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override open func construct(builder: FormBuilder) {
        builder.title = sidebarItem.regularTitle
        builder.forceLinearLayout = true

        builder += LargeTextHeaderFormItem(text: "Person Search Report Coming Soon")
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        
    }
}
