//
//  TrafficInfringementEntitiesReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

extension EvaluatorKey {
    static let trafficInfringmentHasEntity = EvaluatorKey("hasEntity")
}

class TrafficInfringementEntitiesReport: Reportable {
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
            // TODO: create entity manager to determine link between entities and incident
            // TODO: use event.entityManger to return incident specific entities and the check
            return event.entityBucket.entities.count >= 1
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        
    }

    //MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}
