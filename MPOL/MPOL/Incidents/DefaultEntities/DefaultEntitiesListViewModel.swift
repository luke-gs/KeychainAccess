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
        // return entities involved in this incident
        return report.event?.entityBucket.entities.filter {
            report.entityInvolvements[$0.id] != nil
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

    func addEntity(_ entity: MPOLKitEntity, with involvements: [Involvement]) {

        if !entities.contains(entity) {
            report.event?.entityBucket.add(entity)
            report.entityInvolvements[entity.id] = involvements
            report.evaluator.updateEvaluation(for: EvaluatorKey.trafficInfringmentHasEntity)
        }
    }

    func updateEntity(_ entityId: String, with involvements: [Involvement]) {

        report.entityInvolvements[entityId] = involvements
    }

    func removeEntity(_ entity: MPOLKitEntity){
        report.event?.entityBucket.remove(entity)
        report.entityInvolvements[entity.id] = nil
        report.evaluator.updateEvaluation(for: EvaluatorKey.trafficInfringmentHasEntity)
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

    func retrieveInvolvements(for entityId: String) -> [Involvement] {
        return report.entityInvolvements[entityId] ?? []
    }
}
