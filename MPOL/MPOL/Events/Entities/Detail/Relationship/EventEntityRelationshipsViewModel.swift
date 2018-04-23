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
    var dataSources: [EntityDataSource] = []

    init(report: EventEntityRelationshipsReport) {
        self.report = report
        createDatasources()
    }

    func createDatasources() {
        if let entities = entitesFor(Person.self), !entities.isEmpty {
            dataSources.append(EntityDataSource(header: "Persons", entities: entities))
        }

        if let entities = entitesFor(Vehicle.self), !entities.isEmpty {
            dataSources.append(EntityDataSource(header: "Vehicles", entities: entities))
        }
    }

    public func entitesFor(_ entityType: AnyClass) -> [MPOLKitEntity]? {
        switch entityType {
        case is Person.Type:
            return report.event?.entityBucket.entities(for: Person.self).filter{$0 != self.report.entity!}
        case is Vehicle.Type:
            return report.event?.entityBucket.entities(for: Vehicle.self).filter{$0 != self.report.entity!}
        default:
            fatalError("No such entity \(entityType)")
        }
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

    func tintColour() -> UIColor {
        return report.evaluator.isComplete == true ? .midGreen : .red
    }
}

struct EntityDataSource {
    var header: String
    var entities: [MPOLKitEntity]
}

