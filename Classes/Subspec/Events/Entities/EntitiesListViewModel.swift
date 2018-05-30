//
//  EntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol EntitiesListViewModel {

    var report: DefaultEntitiesListReport { get }

    var entityPickerViewModel: EntityPickerViewModel { get }

    var tempInvolvements: [String]? { get set }

    var headerText: String { get }

    var entities: [MPOLKitEntity] { get }

    var currentLoadingManagerState: LoadingStateManager.State { get }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) { get }

    func retrieveInvolvements(for entity: MPOLKitEntity) -> [String]?

    func retrieveAdditionalActions(for entity: MPOLKitEntity) -> [AdditionalAction]?

    func addEntity(_ entity: MPOLKitEntity, with involvements: [String]?, and actions: [AdditionalAction]?)

    func update(_ involvements: [String], for entity: MPOLKitEntity)

    func updateActions(for entity: MPOLKitEntity, with actions: [AdditionalAction])

    func removeEntity(_ entity: MPOLKitEntity)

    func removeAdditionalAction(entity: MPOLKitEntity, action: AdditionalAction)

    func addObserver(_ observer: EvaluationObserverable)

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable

    func involvements(for entity: MPOLKitEntity) -> [String]

    func additionalActions(for entity: MPOLKitEntity) -> [String]

    func editItems(for entity: MPOLKitEntity) -> [IconPickable]

    func definition(for type: EntityPickerType, from context: DefaultEntitiesListViewController, with entity: MPOLKitEntity) -> EntityPickerTypeDefiniton
}

public extension EntitiesListViewModel {

    var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entities.count)
    }

    var entities: [MPOLKitEntity] {
        return report.event?.entityManager.relationships(for: report.incident!).map{ $0.baseObject } ?? []
    }

    var currentLoadingManagerState: LoadingStateManager.State {
        return entities.isEmpty ? .noContent : .loaded
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    func retrieveInvolvements(for entity: MPOLKitEntity) -> [String]? {
        return report.event?.entityManager.relationship(between: entity, and: report.incident!)?.reasons
    }

    func retrieveAdditionalActions(for entity: MPOLKitEntity) -> [AdditionalAction]?  {
        return report.incident!.additionalActionRelationshipManager.relationships(for: entity, and: AdditionalAction.self).compactMap { $0.relatedObject }
    }

    func addObserver(_ observer: EvaluationObserverable) {
        report.evaluator.addObserver(observer)
    }

    func addEntity(_ entity: MPOLKitEntity, with involvements: [String]?, and actions: [AdditionalAction]?) {
        if !entities.contains(entity) {
            report.event?.entityManager.add(entity, to: report.incident!, with: involvements)

            for action in actions ?? [] {
                report.incident!.additionalActionRelationshipManager.add(Relationship(baseObject: entity, relatedObject: action))
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
        }
    }

    func update(_ involvements: [String], for entity: MPOLKitEntity) {
        report.event?.entityManager.update(involvements, between: entity, and: report.incident!)
    }

    func updateActions(for entity: MPOLKitEntity, with actions: [AdditionalAction]) {

        for action in retrieveAdditionalActions(for: entity) ?? [] {
            removeAdditionalAction(entity: entity, action: action)
        }
        actions.forEach {
            report.incident!.additionalActionRelationshipManager.add(Relationship(baseObject: entity, relatedObject: $0))
        }
    }

    func removeEntity(_ entity: MPOLKitEntity) {
        if entities.contains(entity) {
            report.event?.entityManager.remove(entity, from: report.incident!)
            for action in retrieveAdditionalActions(for: entity) ?? [] {
                removeAdditionalAction(entity: entity, action: action)
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
        }
    }

    func removeAdditionalAction(entity: MPOLKitEntity, action: AdditionalAction) {
        report.incident!.additionalActionRelationshipManager.remove(Relationship(baseObject: entity, relatedObject: action))
    }

    func editItems(for entity: MPOLKitEntity) -> [IconPickable] {
        var items = [IconPickable]()
        let image = AssetManager.shared.image(forKey: .edit)
        if !involvements(for: entity).isEmpty {
            items.append(IconPickable(title: "Manage Involvements", subtitle: "involvement", icon: image, tintColor: UIColor.black))
        }
        if !additionalActions(for: entity).isEmpty {
            items.append(IconPickable(title: "Manage Additional Actions", subtitle: "action", icon: image, tintColor: UIColor.black))
        }
        return items
    }

    func definition(for type: EntityPickerType, from context: DefaultEntitiesListViewController, with entity: MPOLKitEntity) -> EntityPickerTypeDefiniton {
        switch type {
        case .additionalAction:
            return AdditionalActionPickerDefinition(for: context, with: entity)
        case .involvement:
            return InvolvementPickerDefinition(for: context, with: entity)
        }
    }
}
