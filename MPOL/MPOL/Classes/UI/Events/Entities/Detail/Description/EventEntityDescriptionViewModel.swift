//
//  EventEntityDescriptionViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

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
        case let organisation as Organisation:
            return OrganisationSummaryDisplayable(organisation)
        case let address as Address:
            return AddressSummaryDisplayable(address)
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
        case is Organisation:
            return nil
        case is Address:
            return nil
        default:
            fatalError("Entity of type \"\(type(of: report.entity))\" not found")
        }
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }
}
