//
//  DefaultEntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

class DefaultEntityPickerViewModel: EntityPickerViewModel {

    let entities: [MPOLKitEntity]
    weak var delegate: EntityPickerDelegate?

    required init() {
        entities = UserSession.current.recentlyViewed.entities
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
