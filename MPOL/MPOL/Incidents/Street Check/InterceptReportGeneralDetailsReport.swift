//
//  InterceptReportGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

open class InterceptReportGeneralDetailsReport: Reportable {

    public weak var event: Event?
    public weak var incident: Incident?
    public let evaluator: Evaluator = Evaluator()

    public var viewed: Bool = false {
    	didSet {
            evaluator.updateEvaluation(for: .viewed)
    	}
    }

    public required init(event: Event, incident: Incident? = nil) {
        self.event = event
        self.incident = incident
        commonInit()
    }

    private func commonInit() {
        if let event = event {
            evaluator.addObserver(event)
        }
        if let incident = incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    // Coding
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case incidents
    }

    public func encode(with aCoder: NSCoder) { }
    public required init?(coder aDecoder: NSCoder) {
    	commonInit()
    }

    // Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}



