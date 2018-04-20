//
//  EventEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class EventEntitiesListViewModel {

    let report: EventEntitiesListReport
    
    public init(report: EventEntitiesListReport) {
        self.report = report
    }

    var headerText: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), report.entities.count)
    }
    
    public func tabColour() -> UIColor {
        return .red
    }

    public func entityFor(_ indexPath: IndexPath) -> MPOLKitEntity {
        return report.entities[indexPath.row]
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
        return report.entities.isEmpty ? .noContent : .loaded
    }
}
