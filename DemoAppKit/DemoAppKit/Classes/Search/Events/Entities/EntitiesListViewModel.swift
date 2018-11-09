//
//  EntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol EntitiesListViewModel {

    var report: DefaultEntitiesListReport { get }

    var building: AdditionalActionBuilding { get }

    var screenBuilding: AdditionalActionScreenBuilding { get }

    var entitySelectionViewModel: EntitySummarySelectionViewModel { get }

    var selectedInvolvements: [String]? { get set }

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

    func report(for action: AdditionalAction) -> ActionReportable
}

public extension EntitiesListViewModel {

    var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entities.count)
    }

    var entities: [MPOLKitEntity] {
        return report.event?.entityManager.relationships(for: report.incident!).compactMap { relationship in
            return report.event?.entities[relationship.baseObjectUuid]
        } ?? []
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

    func retrieveAdditionalActions(for entity: MPOLKitEntity) -> [AdditionalAction]? {
        return report.incident?.additionalActionManager.actionRelationships(for: entity).compactMap { relationship in
            if let actions = report.incident?.actions {
                return actions.first(where: { return $0.uuid == relationship.relatedObjectUuid })
            }
            return nil
        }
    }

    func addObserver(_ observer: EvaluationObserverable) {
        report.evaluator.addObserver(observer)
    }

    func addEntity(_ entity: MPOLKitEntity, with involvements: [String]?, and actions: [AdditionalAction]?) {
        if !entities.contains(entity) {
            report.event?.entityManager.add(entity, to: report.incident!, with: involvements)

            for action in actions ?? [] {
                action.add(report: report(for: action))
                report.incident?.additionalActionManager.add(action, to: entity)
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
            report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
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
            $0.add(report: report(for: $0))
            report.incident?.additionalActionManager.add($0, to: entity)
        }
        report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
    }

    func removeEntity(_ entity: MPOLKitEntity) {
        if entities.contains(entity) {
            report.event?.entityManager.remove(entity, from: report.incident!)
            for action in retrieveAdditionalActions(for: entity) ?? [] {
                removeAdditionalAction(entity: entity, action: action)
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
            report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
        }
    }

    func removeAdditionalAction(entity: MPOLKitEntity, action: AdditionalAction) {
        report.incident?.additionalActionManager.remove(action, from: entity)
        report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
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
