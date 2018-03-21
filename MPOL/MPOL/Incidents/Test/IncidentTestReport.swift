//
//  IncidentTestReport.swift
//  MPOL
//
//  Created by Pavel Boryseiko on 21/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

// TODO: REMOVE THIS CLASS WHEN START INCIDENTS
class IncidentTestReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
    var evaluator: Evaluator = Evaluator()

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }
    
    init(event: Event, incident: Incident) {
        self.event = event
        self.incident = incident

        if let event = self.event { evaluator.addObserver(event) }
        if let incident = self.incident { evaluator.addObserver(incident) }

        evaluator.registerKey(.viewed) { return self.viewed }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

    //MARK: CODING
    public required init(from: Decoder) throws { }
    public func encode(to: Encoder) throws { }
}
