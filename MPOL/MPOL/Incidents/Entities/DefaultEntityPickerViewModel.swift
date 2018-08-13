//
//  DefaultEntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

/// This EntityPickerViewModel suppports `Person` and `Vehicle`.
class DefaultEntityPickerViewModel: EntityPickerViewModel {
    var headerTitle: String
    var entities: [MPOLKitEntity]
    weak var delegate: EntityPickerDelegate?

    public init() {
        headerTitle = "Recently Viewed"
        entities = UserSession.current.recentlyViewed.entities.filter {
            return $0 is Person || $0 is Vehicle
        }
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("No Displayable for Entity Type")
        }
    }
}
