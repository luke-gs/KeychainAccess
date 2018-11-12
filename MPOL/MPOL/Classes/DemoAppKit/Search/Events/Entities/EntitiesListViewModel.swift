//
//  EntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

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
        return report.event?.incidentRelationshipManager?.relationships(for: report.incident!).compactMap { relationship in
            return report.event?.entityBucket.entity(uuid: relationship.baseObjectUuid)
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
        return report.event?.incidentRelationshipManager?.relationship(between: entity, and: report.incident!)?.reasons
    }

    func retrieveAdditionalActions(for entity: MPOLKitEntity) -> [AdditionalAction]? {
        return actionRelationships(for: entity).compactMap { relationship in
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
            report.event?.entityBucket.add(entity)
            report.event?.incidentRelationshipManager?.add(baseObject: entity, relatedObject: report.incident!, reasons: involvements)

            actions?.forEach { action in
                action.add(report: report(for: action))
                addAction(action, to: entity)
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
            report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
        }
    }

    func update(_ involvements: [String], for entity: MPOLKitEntity) {
        report.event?.incidentRelationshipManager?.update(involvements, between: entity, and: report.incident!)
    }

    func updateActions(for entity: MPOLKitEntity, with actions: [AdditionalAction]) {

        for action in retrieveAdditionalActions(for: entity) ?? [] {
            removeAdditionalAction(entity: entity, action: action)
        }
        actions.forEach { action in
            action.add(report: report(for: action))
            addAction(action, to: entity)
        }
        report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
    }

    func removeEntity(_ entity: MPOLKitEntity) {
        if entities.contains(entity) {
            removeEntity(entity, from: report.incident!)
            for action in retrieveAdditionalActions(for: entity) ?? [] {
                removeAdditionalAction(entity: entity, action: action)
            }
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
            report.evaluator.updateEvaluation(for: EvaluatorKey.additionalActionsComplete)
        }
    }

    public func removeEntity(_ entity: MPOLKitEntity, from incident: Incident) {
        guard let relationshipManager = report.event?.incidentRelationshipManager else { return }

        // Remove the relationship between the entity and the incident
        if let incidentRelationship = relationshipManager.relationship(between: entity, and: incident) {
            relationshipManager.remove(incidentRelationship)
        }
        // If the are no more incident->entity relationships, remove the entity and all its relationships
        if relationshipManager.relationships(for: entity, and: Incident.self).isEmpty {
            report.event?.entityBucket.remove(entity)
            report.event?.relationshipManager.removeAll(for: entity)
        }
    }

    func removeAdditionalAction(entity: MPOLKitEntity, action: AdditionalAction) {
        removeAction(action, from: entity)
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

    // MARK: - From AdditionalActionManager

    public func actionRelationships(for entity: MPOLKitEntity) -> [Relationship] {
        return report.incident?.relationshipManager.relationships(for: entity, and: AdditionalAction.self) ?? []
    }

    public func addAction(_ action: AdditionalAction, to entity: MPOLKitEntity) {
        report.incident?.actions.append(action)
        report.incident?.relationshipManager.add(baseObject: entity, relatedObject: action)
    }

    public func removeAction(_ action: AdditionalAction, from entity: MPOLKitEntity) {
        // Remove the relationship between the action and the entity
        if let actionRelationships = report.incident?.relationshipManager.relationship(between: entity, and: action) {
            report.incident?.relationshipManager.remove(actionRelationships)
        }
        // Remove the action
        report.incident?.actions.removeAll(where: { $0 == action })
    }

}
