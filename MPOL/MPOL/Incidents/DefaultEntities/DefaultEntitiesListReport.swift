//
//  DefaultEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

extension EvaluatorKey {
    static let trafficInfringmentHasEntity = EvaluatorKey("hasEntity")
}

class DefaultEntitiesListReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
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

        evaluator.registerKey(.trafficInfringmentHasEntity) {
            guard let event = self.event else { return false }
            guard let incident = self.incident else { return false }
            guard !event.entityManager.relationships(for: incident).isEmpty else { return false }
            return true
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        
    }

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}
