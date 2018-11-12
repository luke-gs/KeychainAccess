//
//  DefaultEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import CoreKit

extension EvaluatorKey {
    static let hasEntity = EvaluatorKey("hasEntity")
    static let additionalActionsComplete = EvaluatorKey("additionalActionsComplete")
}

public class DefaultEntitiesListReport: DefaultReportable {

    private func commonInit() {
        evaluator.registerKey(.hasEntity) { [weak self] in
            guard let `self` = self else { return false }
            guard let event = self.event else { return false }
            guard let incident = self.incident else { return false }
            guard let incidentRelationshipManager = event.incidentRelationshipManager else { return false }
            return !incidentRelationshipManager.relationships(for: incident).isEmpty
        }
        evaluator.registerKey(.additionalActionsComplete) { [weak self] in
            guard let `self` = self else { return false }
            guard let incident = self.incident else { return false }
            return incident.actionsValid
        }
    }

    public override init(event: Event, incident: Incident) {
        super.init(event: event, incident: incident)
        commonInit()
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        commonInit()
    }
}
