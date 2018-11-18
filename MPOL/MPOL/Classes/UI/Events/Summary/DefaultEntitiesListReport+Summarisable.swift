//
//  DefaultEntitiesListReport+Summarisable.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

extension DefaultEntitiesListReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        guard let incident = incident else { return items }

        let entities = event?.incidentRelationshipManager?.relationships(for: incident).compactMap {
            return event?.entityBucket.entity(for: $0.baseObjectUuid)
        }

        if let entities = entities {
            var entityNames = [String]()
            entities.forEach { (entity) in
                var displayable: AssociatedEntitySummaryDisplayable
                switch entity {
                case is Person:
                    displayable = PersonSummaryDisplayable(entity)
                case is Vehicle:
                    displayable = VehicleSummaryDisplayable(entity)
                case is Organisation:
                    displayable = OrganisationSummaryDisplayable(entity)
                case is Address:
                    displayable = AddressSummaryDisplayable(entity)
                default:
                    fatalError("Invalid entity type")
                }
                entityNames.append(displayable.title!.sizing().string)
            }
            items.append(RowDetailFormItem(title: String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entityNames.count), detail: entityNames.joined(separator: ", ")))
        }
        return items
    }
}
