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
        return String.localizedStringWithFormat(NSLocalizedString("%d entities added", comment: ""), entities.count)
    }

    var entities: [MPOLKitEntity] {

        return report.event?.entityBucket.entities ?? []
    }

    var currentLoadingManagerState: LoadingStateManager.State {
        return entities.isEmpty ? .noContent : .loaded
    }

    var tabColor: UIColor {
        return report.evaluator.isComplete ? .midGreen : .red
    }

    func addEntity(_ entity: MPOLKitEntity) {

        if !entitiesContains(entity) {
            report.event?.entityBucket.add(entity)
            report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
        }
    }

    func removeEntity(_ entity: MPOLKitEntity){

        report.event?.entityBucket.remove(entity)
        report.evaluator.updateEvaluation(for: EvaluatorKey.hasEntity)
    }

    func entitiesContains(_ entity: MPOLKitEntity) -> Bool {

        return entities.contains(entity)
    }

    func entitiesCount() -> Int {

        return report.event?.entityBucket.entities.count ?? 0
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
}
