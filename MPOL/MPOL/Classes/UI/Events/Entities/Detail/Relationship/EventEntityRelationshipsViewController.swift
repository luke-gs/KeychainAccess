//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

class EventEntityRelationshipsViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: EventEntityRelationshipsViewModel

    required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    public required init(viewModel: EventEntityRelationshipsViewModel) {
        self.viewModel = viewModel
        super.init()

        self.title = "Relationships"

        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.association)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        loadingManager.noContentView.titleLabel.text = "No Entities"
        loadingManager.noContentView.subtitleLabel.text = "There are no relationships that need to be defined"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)

        viewModel.report.evaluator.addObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.report.viewed = true
        loadingManager.state = viewModel.loadingManagerState()
    }

    override func construct(builder: FormBuilder) {
        viewModel.dataSources.forEach { dataSource in
            builder += HeaderFormItem(text: dataSource.header)
            builder += dataSource.entities.map { entity in
                return viewModel.displayable(for: entity)
                    .summaryListFormItem()
                    .styleIdentifier(DemoAppKitStyler.associationStyle)
                    .badgeColor(nil)
                    .badge(0)
                    .detail(viewModel.relationshipStatus(forEntity: entity))
                    .onSelection({ (cell) in
                        guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                        self.collectionView?.deselectItem(at: indexPath, animated: true)
                        self.presentEntityToEntityRelationshipPickerVC(entity: entity)
                    })
            }
        }
    }

    func presentEntityToEntityRelationshipPickerVC(entity: MPOLKitEntity) {

        let objects: [PickableManifestEntry] = RelationshipReason.reasonsFor(viewModel.report.entity!, entity)

        let selectedObjects: [Pickable]? = viewModel.relationshipWith(relatedEntity: entity)?.reasons
        let dataSource = RelationshipSearchDataSource(objects: objects,
                                                     selectedObjects: selectedObjects,
                                                     title: "Relationships")

        dataSource.header = CustomisableSearchHeaderView()
        let viewController = CustomPickerController(dataSource: dataSource)

        viewController.navigationItem.rightBarButtonItem?.isEnabled = true

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        viewController.finishUpdateHandler = { controller, indexes in
            let reasons = controller.objects.enumerated()
                .filter({ indexes.contains($0.offset) })
                .compactMap({ $0.element.title})

            self.viewModel.applyRelationship(relatedEntity: entity, reasons: reasons)
            self.reloadForm()
            self.dismissAnimated()
        }

        let navController = PopoverNavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismissAnimated()
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}

public struct RelationshipReason {
    static func reasonsFor(_ firstEntity: MPOLKitEntity, _ secondEntity: MPOLKitEntity) -> [PickableManifestEntry] {
        switch (firstEntity, secondEntity) {
        case is (Person, Person):
            return Manifest.shared.entries(for: .eventPersonPersonRelationship)?.pickableList() ?? []
        case is (Vehicle, Person):
            return Manifest.shared.entries(for: .eventPersonVehicleRelationship)?.pickableList() ?? []
        case is (Person, Vehicle):
            return Manifest.shared.entries(for: .eventPersonVehicleRelationship)?.pickableList() ?? []
        case is (Vehicle, Vehicle):
            return Manifest.shared.entries(for: .eventVehicleVehicleRelationship)?.pickableList() ?? []
        default:
            return []
        }
    }
}
