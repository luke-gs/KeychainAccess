//
//  TrafficInfringementOffencesReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let hasOffence = EvaluatorKey("hasOffence")
}

class TrafficInfringementOffencesReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?

    var offences: [Offence] = [] {
        didSet {
            evaluator.updateEvaluation(for: .hasOffence)
        }
    }
    
    let evaluator: Evaluator = Evaluator()

    init(event: Event, incident: Incident) {
        self.event = event
        self.incident = incident

        if let event = self.event {
            evaluator.addObserver(event)
        }
        if let incident = self.incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.hasOffence) {
            return !self.offences.isEmpty
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}

    //MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}

