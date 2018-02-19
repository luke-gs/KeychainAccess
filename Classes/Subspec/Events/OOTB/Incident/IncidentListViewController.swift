//
//  IncidentListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class IncidentListViewController: FormBuilderViewController, EvaluationObserverable {

    var viewModel: IncidentListViewModel

    public init(viewModel: IncidentListViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.report?.evaluator.addObserver(self)

        sidebarItem.regularTitle = "Incidents"
        sidebarItem.compactTitle = "Incidents"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)!
        sidebarItem.color = .red
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "No incident selected"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one incident"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconDocument)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newIncidentHandler))

        loadingManager.state = (viewModel.report?.incidents.isEmpty ?? true) ? .noContent : .loaded
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report?.viewed = true
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Incidents"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "GENERAL")
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }

    //MARK: PRIVATE

    @objc private func newIncidentHandler() {

    }
}
