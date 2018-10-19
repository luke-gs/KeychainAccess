//
//  DefaultEntityPickerViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

/// This EntityPickerViewModel suppports `Person`, `Vehicle` and `Organisation`.
class DefaultEntityPickerViewModel: EntityPickerViewModel {
    var headerTitle: String
    var entities: [MPOLKitEntity]
    weak var delegate: EntityPickerDelegate?

    public init() {
        headerTitle = "Recently Viewed"
        entities = UserSession.current.recentlyViewed.entities
    }

    func displayable(for entity: MPOLKitEntity) -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        case is Organisation:
            return OrganisationSummaryDisplayable(entity)
        case is Address:
            return AddressSummaryDisplayable(entity)
        default:
            fatalError("No Displayable for Entity Type")
        }
    }
}
