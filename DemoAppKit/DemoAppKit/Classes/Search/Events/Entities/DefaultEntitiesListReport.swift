//
//  DefaultEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

extension EvaluatorKey {
    static let hasEntity = EvaluatorKey("hasEntity")
    static let additionalActionsComplete = EvaluatorKey("additionalActionsComplete")
}

public class DefaultEntitiesListReport: Reportable {
    public let weakEvent: Weak<Event>
    public let weakIncident: Weak<Incident>

    public let evaluator: Evaluator = Evaluator()
    
    public init(event: Event, incident: Incident) {
        self.weakEvent = Weak(event)
        self.weakIncident = Weak(incident)

        if let event = self.event {
            evaluator.addObserver(event)
        }
        if let incident = self.incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.hasEntity) {
            guard let event = self.event else { return false }
            guard let incident = self.incident else { return false }
            return !event.entityManager.relationships(for: incident).isEmpty
        }
        evaluator.registerKey(.additionalActionsComplete) {
            guard let incident = self.incident else { return false }
            return incident.additionalActionManager.allValid
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
    }

    // MARK: CODING
    private enum Coding: String {
        case incident
        case event
    }

    public static var supportsSecureCoding: Bool = true

    public required init?(coder aDecoder: NSCoder) {
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        weakIncident = aDecoder.decodeWeakObject(forKey: Coding.incident.rawValue)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
        aCoder.encodeWeakObject(weakObject: weakIncident, forKey: Coding.incident.rawValue)
    }
}
