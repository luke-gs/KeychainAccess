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
        "Traffic Infringement",
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
        sidebarItem.color = (viewModel.report?.evaluator.isComplete ?? false) ? .midGreen : .red
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
        self.updateLoadingManager()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Incidents"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.sectionHeaderTitle())

        let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)?
            .withCircleBackground(tintColor: .black,
                                  circleColor: .red,
                                  style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))

        viewModel.report?.incidents.forEach { incident in
            builder += SummaryListFormItem()
                .title(incident)
                .subtitle("Not yet started")
                .width(.column(1))
                .image(image)
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(ItemAccessory.disclosure)
                .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.viewModel.report?.incidents.remove(at: indexPath.item)
                    self.updateLoadingManager()
                    self.reloadForm()
                })])
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }

    //MARK: PRIVATE

    @objc private func newIncidentHandler() {
        guard let report = viewModel.report else { return }

        let headerConfig = SearchHeaderConfiguration(title: viewModel.searchHeaderTitle(),
                                                     subtitle: viewModel.searchHeaderSubtitle(),
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
            let incidents = controller.objects.enumerated().filter { index.contains($0.offset) }.flatMap { $0.element.title }
            self.viewModel.add(incidents)
            self.updateLoadingManager()
            self.reloadForm()
        }

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func updateLoadingManager() {
        loadingManager.state = (viewModel.report?.incidents.isEmpty ?? true) ? .noContent : .loaded
    }
}
