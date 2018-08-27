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
        self.createDataSources()
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

    public func relationshipWith(relatedEntity: MPOLKitEntity) -> Relationship<MPOLKitEntity, MPOLKitEntity>? {
        guard let entity = report.entity else { return nil }
        return report.event?.entityManager.relationship(between: entity, and: relatedEntity)
    }

    private func hasRelationshipWith(relatedEntity: MPOLKitEntity) -> Bool {
        return relationshipWith(relatedEntity: relatedEntity) != nil
    }

    public func addRelationship(relatedEntity: MPOLKitEntity, reasons: [String]) {
        guard let baseEntity = report.entity else { fatalError("Report did not contain a base entity") }
        report.event?.entityManager.addRelationship(between: baseEntity, and: relatedEntity, with: reasons)
    }

    public func removeRelationship(forEntity: MPOLKitEntity) {
        guard report.entity != nil else { fatalError("Report did not contain a base entity") }
        guard let relationshipToRemove = relationshipWith(relatedEntity: forEntity) else { fatalError("Could not find a relationship between the specified entities") }
        report.event?.entityManager.removeRelationship(relationshipToRemove)
    }

    public func applyRelationship(relatedEntity: MPOLKitEntity, reasons: [String]) {

        if reasons.isEmpty {
            // Handle if reaons is empty, either remove existing relationship if there is one or do nothing
            if hasRelationshipWith(relatedEntity: relatedEntity) {
                removeRelationship(forEntity: relatedEntity)
            }
        } else {
            addRelationship(relatedEntity: relatedEntity, reasons: reasons)
            // Handle either updating the current relationship or adding a new one
            if hasRelationshipWith(relatedEntity: relatedEntity) {
                if let relationshipToUpdate = relationshipWith(relatedEntity: relatedEntity) {
                    relationshipToUpdate.reasons = reasons
                }
            } else {
                addRelationship(relatedEntity: relatedEntity, reasons: reasons)
            }
        }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public func loadingManagerState() -> LoadingStateManager.State {
        return dataSources.isEmpty ? .noContent : .loaded
    }

    func relationshipStatus(forEntity entity: MPOLKitEntity) -> String? {
        return relationshipWith(relatedEntity: entity)?.reasons?.joined(separator: ", ") ?? "No Relationships"
    }

    // MARK: Private

    private func createDataSources() {
        if let entities = entitesFor(Person.self), !entities.isEmpty {
            dataSources.append(EventRelationshipEntityDataSource(header: "Persons", entities: entities))
        }

        if let entities = entitesFor(Vehicle.self), !entities.isEmpty {
            dataSources.append(EventRelationshipEntityDataSource(header: "Vehicles", entities: entities))
        }
    }

    private func entitesFor(_ entityType: Any) -> [MPOLKitEntity]? {
        guard var relationships = report.event?.entityManager.incidentRelationships else { return nil }

        switch entityType {
        case is Person.Type:
            relationships = relationships.filter { $0.baseObject is Person }.filter { $0.baseObject != self.report.entity }
        case is Vehicle.Type:
            relationships = relationships.filter { $0.baseObject is Vehicle }.filter { $0.baseObject != self.report.entity }
        default:
            fatalError("No such entity \(entityType)")
        }
        return Array(Set(relationships.compactMap { $0.baseObject }))
    }
}

struct EventRelationshipEntityDataSource {
    var header: String
    var entities: [MPOLKitEntity]
}
