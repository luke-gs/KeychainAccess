//
//  EventEntityRelationshipsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

class EventEntityRelationshipsViewModel {

    var report: EventEntityRelationshipsReport
    var dataSources: [EventRelationshipEntityDataSource] = []

    init(report: EventEntityRelationshipsReport) {
        self.report = report
        self.createDatasources()
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

    public func tintColour() -> UIColor {
        return report.evaluator.isComplete == true ? .midGreen : .red
    }

    public func loadingManagerState() -> LoadingStateManager.State {
        return dataSources.isEmpty ? .noContent : .loaded
    }


    //MARK: Private

    private func createDatasources() {
        if let entities = entitesFor(Person.self), !entities.isEmpty {
            dataSources.append(EventRelationshipEntityDataSource(header: "Persons", entities: entities))
        }

        if let entities = entitesFor(Vehicle.self), !entities.isEmpty {
            dataSources.append(EventRelationshipEntityDataSource(header: "Vehicles", entities: entities))
        }
    }

    private func entitesFor(_ entityType: AnyClass) -> [MPOLKitEntity]? {
        switch entityType {
        case is Person.Type:
            return report.event?.entityBucket.entities(for: Person.self).filter{$0 != self.report.entity!}
        case is Vehicle.Type:
            return report.event?.entityBucket.entities(for: Vehicle.self).filter{$0 != self.report.entity!}
        default:
            fatalError("No such entity \(entityType)")
        }
    }
}

struct EventRelationshipEntityDataSource {
    var header: String
    var entities: [MPOLKitEntity]
}

