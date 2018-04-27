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

    unowned var report: EventEntityDescriptionReport

    init(report: EventEntityDescriptionReport) {
        self.report = report
    }

    func displayable() -> EntitySummaryDisplayable {
        switch report.entity {
        case let person as Person:
            return PersonSummaryDisplayable(person)
        case let vehicle as Vehicle:
            return VehicleSummaryDisplayable(vehicle)
        default:
            fatalError("Entity of type \"\(type(of: report.entity))\" not found")
        }
    }

    func description() -> String? {
        switch report.entity {
        case let person as Person:
            return person.descriptions?.first?.formatted()
        case let vehicle as Vehicle:
            return vehicle.vehicleDescription
        default:
            fatalError("Entity of type \"\(type(of: report.entity))\" not found")
        }
    }

    func tintColour() -> UIColor {
       return report.evaluator.isComplete == true ? .midGreen : .red
    }
}
