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
    public var weakEvent: Weak<Event>
    public var weakIncident: Weak<Incident>

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
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.hasEntity) { [weak self] in
            guard let `self` = self else { return false }
            guard let event = self.event else { return false }
            guard let incident = self.incident else { return false }
            return !event.entityManager.relationships(for: incident).isEmpty
        }
        evaluator.registerKey(.additionalActionsComplete) { [weak self] in
            guard let `self` = self else { return false }
            guard let incident = self.incident else { return false }
            return incident.additionalActionManager.allValid
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        weakEvent = Weak<Event>(nil)
        weakIncident = Weak<Incident>(nil)
        commonInit()
    }

    open func encode(to encoder: Encoder) throws {
    }
}
