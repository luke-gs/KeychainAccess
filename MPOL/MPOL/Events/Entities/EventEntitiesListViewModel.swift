//
//  EventEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class EventEntitiesListViewModel: Evaluatable, EntityBucketDelegate {
    
    let report: EventEntitiesListReport
    public var evaluator: Evaluator { return report.evaluator }

    public init(report: EventEntitiesListReport) {
        self.report = report
        report.event?.entityBucket.delegate = self
    }

    var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), report.entityDetailReports.count)
    }
    
    public func tabColour() -> UIColor {
        return evaluator.isComplete ? .midGreen : .red
    }

    public func reportFor(_ indexPath: IndexPath) -> EventEntityDetailReport {
        return report.entityDetailReports[indexPath.row]
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("Entity is Not a valid Type")
        }
    }

    func loadingManagerState() -> LoadingStateManager.State {
        return report.entityDetailReports.isEmpty ? .noContent : .loaded
    }

    func updateReports() {
        var reports = self.report.entityDetailReports

        //Remove reports that no longer have entities
        for report in reports {
            if self.report.event?.entityBucket.contains(report.entity) == false {
                reports.remove(at: reports.index(where: {$0 == report})!)
            }
        }

        //Create and add new entities
        for entity in report.event?.entityBucket.entities ?? [] {
            if !reports.contains(where: {$0.entity == entity}) {
                let report = EventEntityDetailReport(entity: entity, event: self.report.event)
                report.evaluator.addObserver(report)
                reports.append(report)
            }
        }

        self.report.entityDetailReports = reports
    }

    //MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

    //MARK: EntityBucketDelegate
    public func entitiesDidChange() {
        updateReports()
    }
}
