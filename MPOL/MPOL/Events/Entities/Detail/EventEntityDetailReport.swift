//
//  EventEntityDetailReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey("allValid")
}

public class EventEntityDetailReport: Reportable {

    public weak var event: Event?
    public weak var incident: Incident?
    public unowned var entity: MPOLKitEntity

    public let descriptionReport: EventEntityDescriptionReport
    public let relationshipsReport: EventEntityRelationshipsReport
    public var reports: [Reportable] {
        return [
            descriptionReport,
            relationshipsReport
        ]
    }

    public init(entity: MPOLKitEntity) {
        self.entity = entity

        descriptionReport = EventEntityDescriptionReport(event: event, entity: entity)
        relationshipsReport = EventEntityRelationshipsReport(event: event, entity: entity)

        descriptionReport.evaluator.addObserver(self)
        relationshipsReport.evaluator.addObserver(self)

        evaluator.registerKey(.allValid) {
            return self.reports.reduce(true, { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            })
        }
    }

    //Coding
    public static var supportsSecureCoding: Bool = true
    public func encode(with aCoder: NSCoder) { }
    required public init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }

    //Eval
    public var evaluator: Evaluator = Evaluator()
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        self.evaluator.updateEvaluation(for: .allValid)
    }

    //Equatable
    public static func == (lhs: EventEntityDetailReport, rhs: EventEntityDetailReport) -> Bool {
        return lhs.entity == rhs.entity
    }
}
