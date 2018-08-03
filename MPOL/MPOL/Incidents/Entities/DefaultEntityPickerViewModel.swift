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

    var entities: [MPOLKitEntity] {
        return UserSession.current.recentlyViewed.entities.filter {
            return $0 is Person || $0 is Vehicle
        }
    }

    weak var delegate: EntityPickerDelegate?

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
