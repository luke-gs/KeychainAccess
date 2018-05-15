//
//  DomesticViolencePropertyReport.swift
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

class DomesticViolencePropertyReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
    let evaluator: Evaluator = Evaluator()

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    init(event: Event, incident: Incident) {
        self.event = event
        self.incident = incident

        if let event = self.event {
            evaluator.addObserver(event)
        }
        if let incident = self.incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}
