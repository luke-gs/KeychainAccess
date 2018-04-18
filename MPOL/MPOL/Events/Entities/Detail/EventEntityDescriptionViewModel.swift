//
//  EventEntityDescriptionViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

open class EventEntityDescriptionViewModel {

    unowned var entity: MPOLKitEntity

    init(entity: MPOLKitEntity) {
        self.entity = entity
    }

    func displayable() -> EntitySummaryDisplayable {
        switch entity {
        case is Person:
            return PersonSummaryDisplayable(entity)
        case is Vehicle:
            return VehicleSummaryDisplayable(entity)
        default:
            fatalError("Entity of type \"\(type(of: entity))\" not found")
        }
    }

    func description() -> String? {
        switch entity {
        case let person as Person:
            return person.descriptions?.first?.formatted()
        case let vehicle as Vehicle:
            return vehicle.vehicleDescription
        default:
            fatalError("Entity of type \"\(type(of: entity))\" not found")
        }
    }
}
