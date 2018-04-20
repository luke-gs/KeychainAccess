//
//  EventEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import Foundation

fileprivate extension EvaluatorKey {
    static let valid = EvaluatorKey("valid")
}

public class EventEntitiesListReport : Reportable, Evaluatable {
    public weak var event: Event?
    public weak var incident: Incident?
    
    public let evaluator: Evaluator = Evaluator()
    public var entityDetailReports: [EventEntityDetailReport] = [EventEntityDetailReport]()
    
    public init(event: Event) {
        self.event = event

        evaluator.registerKey(.valid) {
            let reportsValid = self.entityDetailReports.reduce(true, { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            })
            return !self.entityDetailReports.isEmpty && reportsValid
        }
    }
    
    //MARK: Coding
    public static var supportsSecureCoding: Bool { return true }
    public func encode(with aCoder: NSCoder) { }
    public required init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }
    
    //MARK: Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        self.evaluator.updateEvaluation(for: [.valid])
    }
}
