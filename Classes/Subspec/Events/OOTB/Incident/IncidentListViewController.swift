//
//  IncidentListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class IncidentListViewController: FormBuilderViewController, EvaluationObserverable {

    // TEMP INCIDENTS
    fileprivate let incidents = [
        "Traffic Infringements",
        "Traffic Crash",
        "Roadside Drug Testing",
        "Public Nuisance",
        "Domestic Violence"
    ]

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
        guard let report = viewModel.report else { return }

        let headerConfig = SearchHeaderConfiguration(title: "No incident selected",
                                                     subtitle: "",
                                                     image: AssetManager.shared.image(forKey: .iconPencil)?
                                                        .withCircleBackground(tintColor: .white,
                                                                              circleColor: .primaryGray,
                                                                              style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                            padding: .zero)),
                                                     imageStyle: .circle)

        let datasource = IncidentSearchDataSource(objects: incidents,
                                                  selectedObjects: report.incidents,
                                                  configuration: headerConfig)
        
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let viewController = CustomPickerController(datasource: datasource)

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        viewController.finishUpdateHandler = { controller, index in
            self.reloadForm()
        }

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }
}
