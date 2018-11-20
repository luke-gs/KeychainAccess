//
//  EventEntityDetailReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey("allValid")
}

public class EventEntityDetailReport: DefaultEventReportable {

    // Uuid of the entity
    public var entityUuid: String

    /// Return the entity from the event
    public var entity: MPOLKitEntity? {
        return event?.entityBucket.entity(for: entityUuid)
    }

    public let descriptionReport: EventEntityDescriptionReport
    public let relationshipsReport: EventEntityRelationshipsReport

    public var reports: [EventReportable] {
        return [
            descriptionReport,
            relationshipsReport
        ]
    }

    public init(entity: MPOLKitEntity, event: Event) {
        entityUuid = entity.uuid
        descriptionReport = EventEntityDescriptionReport(event: event, entity: entity)
        relationshipsReport = EventEntityRelationshipsReport(event: event, entity: entity)

        super.init(event: event)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.allValid) { [weak self] in
            return self?.reports.reduce(true) { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            } ?? false
        }
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        // Pass on the event to child reports
        descriptionReport.weakEvent = Weak(event)
        relationshipsReport.weakEvent = Weak(event)

        // Observe changes to child report evaluators
        descriptionReport.evaluator.addObserver(self)
        relationshipsReport.evaluator.addObserver(self)

        /*
         for demo purpose, setting viewed to true allow validation to pass straightly
         without adding relationship.
         */
        descriptionReport.viewed = true
        relationshipsReport.viewed = true
    }

    // Eval
    public override func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        // Update our evaluator if any evaluator we are observing changes
        self.evaluator.updateEvaluation(for: .allValid)
    }

    // Equatable
    public static func == (lhs: EventEntityDetailReport, rhs: EventEntityDetailReport) -> Bool {
        return lhs.entity == rhs.entity
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case entityUuid
        case descriptionReport
        case relationshipsReport
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entityUuid = try container.decode(String.self, forKey: .entityUuid)
        descriptionReport = try container.decode(EventEntityDescriptionReport.self, forKey: .descriptionReport)
        relationshipsReport = try container.decode(EventEntityRelationshipsReport.self, forKey: .relationshipsReport)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entityUuid, forKey: CodingKeys.entityUuid)
        try container.encode(descriptionReport, forKey: CodingKeys.descriptionReport)
        try container.encode(relationshipsReport, forKey: CodingKeys.relationshipsReport)
    }

}
