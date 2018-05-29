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
        loadingManager.noContentView.actionButton.addTarget(self, action: #selector(performAddIncidentAction), for: .touchUpInside)
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

        if let primaryIncident = viewModel.primaryIncident {
            let headerItem = HeaderFormItem(text: "Primary Incident")
            if viewModel.incidentList.count > 1 {
                headerItem.actionButton(title: "Change", handler: choosePrimaryIncidentHandler(_:))
            }

            builder += headerItem
            // We only want to allow the user to remove the primary incident if there are any additional incidents
            let primaryEditActions = viewModel.additionalIncidents?.isEmpty ?? true ? [] : [CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in

                guard let incident = self.viewModel.incident(for: primaryIncident), let count = self.viewModel.additionalIncidents?.count else { return }
                // If there is more than one additional incident, we want the user to choose which incident will become the new primary
                if count > 1 {
                    self.performDeletePrimaryAction()
                } else {
                    self.viewModel.removeIncident(incident)
                }

                self.updateLoadingManager()
                self.reloadForm()
            })]

            builder += SummaryListFormItem()
                .title(primaryIncident.title)
                .subtitle(viewModel.subtitle(for: primaryIncident))
                .width(.column(1))
                .image(viewModel.image(for: primaryIncident))
                .selectionStyle(.none)
                .imageStyle(.circle)
                .accessory(ItemAccessory.disclosure)
                .editActions(primaryEditActions)
                .onSelection { cell in
                    guard let incident = self.viewModel.incident(for: primaryIncident) else { return }
                    let vc = IncidentSplitViewController(viewModel: self.viewModel.detailsViewModel(for: incident))
                    self.parent?.navigationController?.pushViewController(vc, animated: true)
            }
        }

        builder += HeaderFormItem(text: viewModel.additionalIndicentsSectionHeaderTitle()).actionButton(title: "Add", handler: newIncidentHandler(_:))

        if let additionalIncidents = viewModel.additionalIncidents, !additionalIncidents.isEmpty {
            additionalIncidents.forEach { displayable in
                builder += SummaryListFormItem()
                    .title(displayable.title)
                    .subtitle(viewModel.subtitle(for: displayable))
                    .width(.column(1))
                    .image(viewModel.image(for: displayable))
                    .selectionStyle(.none)
                    .imageStyle(.circle)
                    .accessory(ItemAccessory.disclosure)
                    .editActions([CollectionViewFormEditAction(title: "Remove", color: UIColor.red, handler: { (cell, indexPath) in
                        guard let incident = self.viewModel.incident(for: displayable) else { return }
                        self.viewModel.removeIncident(incident)
                        self.updateLoadingManager()
                        self.reloadForm()
                    })])
                    .onSelection { cell in
                        guard let incident = self.viewModel.incident(for: displayable) else { return }
                        let vc = IncidentSplitViewController(viewModel: self.viewModel.detailsViewModel(for: incident))
                        self.parent?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    func performIncidentAction(actionType: IncidentActionType) {

        let actionDefinition = viewModel.definition(for: actionType, from: self)

        let viewController = CustomPickerController(datasource: actionDefinition.datasource)

        viewController.allowsMultipleSelection = actionDefinition.canSelectMultiple

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(cancelTapped))

        viewController.finishUpdateHandler = actionDefinition.completion


        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)

    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    public func updateLoadingManager() {
        loadingManager.state = viewModel.incidentList.isEmpty ? .noContent : .loaded
    }

    // MARK: - PRIVATE

    @objc private func newIncidentHandler(_ sender: UIButton) {
        performAddIncidentAction()
    }

    @objc private func choosePrimaryIncidentHandler(_ sender: UIButton) {
        performChoosePrimaryAction()
    }

    @objc private func performAddIncidentAction() {
        performIncidentAction(actionType: .add)
    }

    @objc private func performChoosePrimaryAction() {
        performIncidentAction(actionType: .choosePrimary)
    }

    @objc private func performDeletePrimaryAction() {
        performIncidentAction(actionType: .deletePrimary)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }
}
