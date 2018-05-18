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
    
    public let report: EventEntitiesListReport
    public var evaluator: Evaluator { return report.evaluator }

    public init(report: EventEntitiesListReport) {
        self.report = report
        report.event?.entityManager.delegate = self
    }

    public var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), report.entityDetailReports.count)
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public func reportFor(_ indexPath: IndexPath) -> EventEntityDetailReport {
        return report.entityDetailReports[indexPath.row]
    }

    public func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("Entity is Not a valid Type")
        }
    }

    public func loadingManagerState() -> LoadingStateManager.State {
        return report.entityDetailReports.isEmpty ? .noContent : .loaded
    }

    public func updateReports() {
        var reports = self.report.entityDetailReports

        // Remove reports that no longer have entities
        for report in reports {
            if self.report.event?.entityManager.incidentRelationships.contains(where: {$0.baseObject == report.entity}) == false {
                reports.remove(at: reports.index(where: {$0 == report})!)
            }
        }

        // Create and add new entities
        guard let entities = self.report.event?.entityManager.incidentRelationships.compactMap({ $0.baseObject }) else {
            return
        }

        for entity in entities {
            if !reports.contains(where: {$0.entity == entity}) {
                let report = EventEntityDetailReport(entity: entity, event: self.report.event)
                report.evaluator.addObserver(report)
                reports.append(report)
            }
        }

        self.report.entityDetailReports = reports
    }

    public func relationshipStatusFor(_ item: Int) -> String? {
        return report.entityDetailReports[item].evaluator.isComplete ? nil : "Unspecified Relationships"
    }

    // This can always return red because if relationships are valid then the status is a nil string, meaning no text is displayed
    public func invalidRelationshipsColor() -> Theme.ColorKey {
        return .redText
    }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: EntityBucketDelegate
    public func entitiesDidChange() {
        // Reset validation of relationship report if entities have changed
        report.entityDetailReports.forEach{ $0.relationshipsReport.viewed = false }

        updateReports()
    }
}
