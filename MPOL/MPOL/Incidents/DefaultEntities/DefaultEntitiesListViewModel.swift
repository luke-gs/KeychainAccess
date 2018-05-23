//
//  DefaultEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class DefaultEntitiesListViewModel {

    let report: DefaultEntitiesListReport

    init(report: DefaultEntitiesListReport) {
        self.report = report
    }

    var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entities.count)
    }

    var entities: [MPOLKitEntity] {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        return report.event?.entityManager.relationships(for: incident).map{ $0.baseObject } ?? []
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

    func addEntity(_ entity: MPOLKitEntity, with involvements: [String]) {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        if !entities.contains(entity) {
            report.event?.entityManager.add(entity, to: incident, with: involvements)
            report.evaluator.updateEvaluation(for: EvaluatorKey.trafficInfringmentHasEntity)
        }
    }

    func update(_ involvements: [String], for entity: MPOLKitEntity) {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        report.event?.entityManager.update(involvements, between: entity, and: incident)
    }

    func removeEntity(_ entity: MPOLKitEntity) {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        if entities.contains(entity) {
            report.event?.entityManager.remove(entity, from: incident)
            report.evaluator.updateEvaluation(for: EvaluatorKey.trafficInfringmentHasEntity)
        }
    }

    func addObserver(_ observer: EvaluationObserverable) {
        report.evaluator.addObserver(observer)
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity{
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("No valid displayable for entity: \(entity.id)")
        }
    }

    func retrieveInvolvements(for entity: MPOLKitEntity) -> [String]? {
        guard let incident = report.incident else { fatalError("Incident Doesn't Exist") }
        return report.event?.entityManager.relationship(between: entity, and: incident)?.reasons
    }
}
