//
//  TrafficInfringementEntitiesViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class TrafficInfringementEntitiesViewModel {

    let report: TrafficInfringementEntitiesReport

    init(report: TrafficInfringementEntitiesReport) {
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

    var tabColor: UIColor {
        return report.evaluator.isComplete ? .midGreen : .red
    }

    func addEntity(_ entity: MPOLKitEntity, with involvements: [Involvement]) {

        if !entities.contains(entity) {
            report.event?.entityBucket.add(entity)
            report.entityInvolvements[entity.id] = involvements
            report.evaluator.updateEvaluation(for: EvaluatorKey.trafficInfringmentHasEntity)
        }
    }

    func removeEntity(_ entity: MPOLKitEntity) {
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
            fatalError("Entity is Not a valid Type")
        }
    }

    func retrieveInvolvements(for entityId: String) -> [Involvement] {
        return report.entityInvolvements[entityId] ?? []
    }
}
