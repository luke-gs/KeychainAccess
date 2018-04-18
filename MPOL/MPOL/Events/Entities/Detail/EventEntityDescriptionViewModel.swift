//
//  EventEntityDescriptionViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

open class EventEntityDescriptionViewModel: Evaluatable {

    unowned var entity: MPOLKitEntity
    public let evaluator: Evaluator = Evaluator()
    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    init(entity: MPOLKitEntity) {
        self.entity = entity

        evaluator.registerKey(.viewed) { () -> (Bool) in
            self.viewed
        }
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

    func tintColour() -> UIColor {
       return evaluator.isComplete == true ? .midGreen : .red
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}
}
