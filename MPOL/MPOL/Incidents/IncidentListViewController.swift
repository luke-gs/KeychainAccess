//
//  IncidentListViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class IncidentListViewController: FormBuilderViewController, EvaluationObserverable {

    var viewModel: IncidentListViewModel

    public init(viewModel: IncidentListViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.report.evaluator.addObserver(self)

        sidebarItem.regularTitle = "Incidents"
        sidebarItem.compactTitle = "Incidents"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.document)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        loadingManager.noContentView.titleLabel.text = "No Incident Selected"
        loadingManager.noContentView.subtitleLabel.text = "This report requires at least one incident"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.iconDocument)
        loadingManager.noContentView.actionButton.setTitle("Add Incident", for: .normal)
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(newIncidentHandler), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newIncidentHandler))
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.report.viewed = true
        viewModel.report.updateEval()
        reloadForm()
        updateLoadingManager()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = "Incidents"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.sectionHeaderTitle())

        viewModel.incidentList.forEach { displayable in
            builder += SummaryListFormItem()
                .title(displayable.title)
                .subtitle("Not yet started")
                .width(.column(1))
                .image(viewModel.image(for: displayable))
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(ItemAccessory.disclosure)
                .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                    self.viewModel.removeIncident(at: indexPath)
                    self.updateLoadingManager()
                    self.reloadForm()
                })])
                .onSelection { cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    guard let incident = self.viewModel.incident(for: self.viewModel.incidentList[indexPath.row]) else { return }
                    let vc = IncidentSplitViewController(viewModel: self.viewModel.detailsViewModel(for: incident))
                    self.parent?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    // MARK: - PRIVATE

    @objc private func newIncidentHandler() {
        let headerConfig = SearchHeaderConfiguration(title: viewModel.searchHeaderTitle(),
                                                     subtitle: viewModel.searchHeaderSubtitle(),
                                                     image: AssetManager.shared.image(forKey: .iconPencil)?
                                                        .withCircleBackground(tintColor: .white,
                                                                              circleColor: .primaryGray,
                                                                              style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                            padding: .zero)),
                                                     imageStyle: .circle)

        let datasource = IncidentSearchDataSource(objects: IncidentType.allIncidentTypes().map { $0.rawValue },
                                                  selectedObjects: viewModel.report.incidents.map { $0.displayable.title! },
                                                  configuration: headerConfig)
        
        datasource.header = CustomisableSearchHeaderView(displayView: DefaultSearchHeaderDetailView(configuration: headerConfig))

        let viewController = CustomPickerController(datasource: datasource)

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(cancelTapped))

        viewController.finishUpdateHandler = { controller, index in
            let incidents = controller.objects.enumerated().filter { index.contains($0.offset) }.compactMap { $0.element.title }
            self.viewModel.add(incidents)
            self.updateLoadingManager()
            self.reloadForm()
        }

        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet

        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    private func updateLoadingManager() {
        loadingManager.state = viewModel.incidentList.isEmpty ? .noContent : .loaded
    }
}
