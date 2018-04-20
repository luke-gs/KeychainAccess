//
//  EventEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit
import Foundation

fileprivate extension EvaluatorKey {
    static let valid = EvaluatorKey("hasEntity")
}

public class EventEntitiesListReport : Reportable {
    public var event: Event?
    public var incident: Incident?

    public var entities: [MPOLKitEntity] {
        return event?.entityBucket.entities ?? []
    }

    public var reports: [Reportable] {
        return []
    }

    public init(event: Event) {
        self.event = event

        evaluator.registerKey(.valid) {
            let reportsValid = self.reports.reduce(true, { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            })
            return self.entities.isEmpty ? true : reportsValid
        }
    }

    public let evaluator: Evaluator = Evaluator()
    
    public static var supportsSecureCoding: Bool { return true }
    public func encode(with aCoder: NSCoder) {
        
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //need to implement
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        
    }
}
