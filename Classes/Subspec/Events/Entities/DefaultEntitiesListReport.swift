//
//  DefaultEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

extension EvaluatorKey {
    static let hasEntity = EvaluatorKey("hasEntity")
}

public class DefaultEntitiesListReport: Reportable {
    public private(set) weak var event: Event?
    public private(set) weak var incident: Incident?
    public let evaluator: Evaluator = Evaluator()
    
    public init(event: Event, incident: Incident) {
        self.event = event
        self.incident = incident

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
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
    }

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}
