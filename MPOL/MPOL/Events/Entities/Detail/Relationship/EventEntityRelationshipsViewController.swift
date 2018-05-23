//
//  EventEntityRelationshipsViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

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
        viewModel.dataSources.forEach { datasource in
            builder += HeaderFormItem(text: datasource.header)
            builder += datasource.entities.map { entity in
                return viewModel.displayable(for: entity)
                    .summaryListFormItem()
                    .badgeColor(nil)
                    .badge(0)
                    .detail(viewModel.relationshipStatus(forEntity: entity))
                    .detailFont(UIFont.systemFont(ofSize: 11, weight: .semibold))
                    .detailColorKey(.primaryText)
                    .onSelection({ (cell) in
                        guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                        self.collectionView?.deselectItem(at: indexPath, animated: true)
                        self.presentEntityToEntityRelationshipPickerVC(entity: entity)
                    })
            }
        }
    }

    func presentEntityToEntityRelationshipPickerVC(entity: MPOLKitEntity) {

        let objects: [Pickable] = RelationshipReason.reasonsFor(viewModel.report.entity!, entity)

        let selectedObjects: [Pickable] = viewModel.relationshipWith(relatedEntity: entity)?.reasons ?? []
        let datasource = RelationshipSearchDatasource(objects: objects,
                                                     selectedObjects: selectedObjects,
                                                     title: "Relationships")

        datasource.header = CustomisableSearchHeaderView()
        let viewController = CustomPickerController(datasource: datasource)

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

public enum RelationshipReason: String, Pickable {

    public var title: String? {
        return self.rawValue
    }
    public var subtitle: String? {
        return nil
    }

    case parent = "Parent"
    case sibling = "Sibling"
    case cousin = "Cousin"
    case friend = "Friend"
    case coWorker = "Co-worker"
    case drivenBy = "Driven By"
    case collidedWith = "Collided With"
    case ownedBy = "Owned By"
    case driver = "Driver"
    case registeredOwner = "Registered Owner"
    case seenIn = "Seen In"
    case seenNearTo = "Seen Near To"
    case passenger = "Passenger"
    case drovePast = "Drove Past"
    case other = "Other"

    static func reasonsFor(_ firstEntity: MPOLKitEntity, _ secondEntity: MPOLKitEntity) -> [RelationshipReason] {

        switch (firstEntity, secondEntity) {
        case is (Person, Person):
            return [.parent, .sibling, .cousin, .friend, .coWorker, .other]
        case is (Vehicle, Person):
            return [.drivenBy, .collidedWith, .ownedBy, .other]
        case is (Person, Vehicle):
            return [.driver, .registeredOwner, .seenIn, .seenNearTo, .passenger, .other]
        case is (Vehicle, Vehicle):
            return [.collidedWith, .drovePast, .other]
        default:
            return []
        }
    }
}
