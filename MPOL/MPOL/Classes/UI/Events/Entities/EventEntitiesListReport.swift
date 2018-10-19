//
//  EventEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit
import Foundation

fileprivate extension EvaluatorKey {
    static let valid = EvaluatorKey("valid")
}

public class EventEntitiesListReport: EventReportable, Evaluatable {
    public let weakEvent: Weak<Event>

    public let evaluator: Evaluator = Evaluator()
    public var entityDetailReports: [EventEntityDetailReport] = [EventEntityDetailReport]() {
        didSet {
            evaluator.updateEvaluation(for: .valid)
        }
    }

    public init(event: Event) {
        self.weakEvent = Weak(event)

        evaluator.addObserver(event)

        evaluator.registerKey(.valid) { [weak self] in
            guard let `self` = self else { return false }
            let reportsValid = self.entityDetailReports.reduce(true, { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            })
            return !self.entityDetailReports.isEmpty && reportsValid
        }
    }

    // MARK: Coding
    public static var supportsSecureCoding: Bool { return true }
    public func encode(with aCoder: NSCoder) {}

    public required init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }

    // MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
    }
}
