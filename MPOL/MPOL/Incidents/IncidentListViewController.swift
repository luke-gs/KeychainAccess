//
//  IncidentListViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

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
        viewModel.report?.updateEval()
        reloadForm()
        updateLoadingManager()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Incidents"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.sectionHeaderTitle())

        viewModel.report?.incidentDisplayables.enumerated().forEach { index, incident in

            let eval = self.viewModel.report?.incidents[index].evaluator.isComplete ?? false
            let image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)?
                .withCircleBackground(tintColor: .black,
                                      circleColor: eval ? .midGreen : .red,
                                      style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))

            builder += SummaryListFormItem()
                .title(incident.title)
                .subtitle("Not yet started")
                .width(.column(1))
                .image(image)
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(ItemAccessory.disclosure)
                .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.viewModel.report?.incidents.remove(at: indexPath.item)
                    self.viewModel.report?.incidentDisplayables.remove(at: indexPath.item)
                    self.updateLoadingManager()
                    self.reloadForm()
                })])
                .onSelection { cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    guard let incident = self.viewModel.report?.incidents[indexPath.item] else { return }

                    let vc = IncidentSplitViewController(viewModel: self.viewModel.detailsViewModel(for: incident))

                    self.present(vc, animated: true, completion: nil)
            }
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
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

        let datasource = IncidentSearchDataSource(objects: IncidentType.allIncidentTypes().map{$0.rawValue},
                                                  selectedObjects: report.incidentDisplayables.map{$0.title!},
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
        dismissAnimated()
    }

    private func updateLoadingManager() {
        loadingManager.state = (viewModel.report?.incidents.isEmpty ?? true) ? .noContent : .loaded
    }
}
