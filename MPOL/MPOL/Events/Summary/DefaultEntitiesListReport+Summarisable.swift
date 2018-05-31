//
//  DefaultEntitiesListReport+Summarisable.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

extension DefaultEntitiesListReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()

        if let incident = incident, let entities = event?.entityManager.relationships(for: incident).map({$0.baseObject}) {
            var entityNames = [String]()
            entities.forEach { (entity) in
                switch entity {
                case is Person:
                    let displayable = PersonSummaryDisplayable(entity)
                    entityNames.append(displayable.title!)
                case is Vehicle:
                    let displayable = VehicleSummaryDisplayable(entity)
                    entityNames.append(displayable.title!)
                default:
                    fatalError("Invalid entity type")
                }
            }
            items.append(RowDetailFormItem(title: String.localizedStringWithFormat(NSLocalizedString("%d entities", comment: ""), entityNames.count), detail: entityNames.joined(separator: ", ")))
        }
        return items
    }
}
