//
//  DefaultEntitiesListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

class DefaultEntitiesListViewModel: EntitiesListViewModel {

    let report: DefaultEntitiesListReport
    let incidentType: IncidentType
    var entityPickerViewModel: EntityPickerViewModel = DefaultEntityPickerViewModel()
    var tempInvolvements: [String]? = nil

    required init(report: DefaultEntitiesListReport, incidentType: IncidentType) {
        self.report = report
        self.incidentType = incidentType
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

    func involvements(for entity: MPOLKitEntity) -> [String] {

        return incidentType.involvements(for: entity)
    }

    func additionalActions(for entity: MPOLKitEntity) -> [String] {

        var types = [AdditionalActionType]()
        switch entity {
        case is Person:
            // "Custody Report", "Referral Report"
            types = [.personSearch]
        case is Vehicle:
            // "Vehicle Tow Report", "Vehicle MVC Report", "Vehicle Search"
            types = [.vehicleTow]
        default:
            break
        }
        return types.map { $0.rawValue }

    }
}
