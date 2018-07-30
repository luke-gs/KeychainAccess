//
//  DefaultEntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import ClientKit

class DefaultEntityPickerViewModel: EntityPickerViewModel {

    var entities: [MPOLKitEntity] {
        return UserSession.current.recentlyViewed.entities
    }
    weak var delegate: EntityPickerDelegate?

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {

        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        case is Address:
            return AddressSummaryDisplayable(entity)
        default:
            fatalError("No Displayable for Entity Type")
        }
    }
}
