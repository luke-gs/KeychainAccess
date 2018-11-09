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

    // TODO: persist entity id
    public weak var entity: MPOLKitEntity?

    public let descriptionReport: EventEntityDescriptionReport
    public let relationshipsReport: EventEntityRelationshipsReport

    public var reports: [EventReportable] {
        return [
            descriptionReport,
            relationshipsReport
        ]
    }

    public override var weakEvent: Weak<Event> {
        didSet {
            // Update child reports
            descriptionReport.weakEvent = weakEvent
            relationshipsReport.weakEvent = weakEvent
        }
    }

    public init(entity: MPOLKitEntity, event: Event) {
        self.entity = entity
        descriptionReport = EventEntityDescriptionReport(event: event, entity: entity)
        relationshipsReport = EventEntityRelationshipsReport(event: event, entity: entity)

        super.init(event: event)

        /*
         for demo purpose, setting viewed to true allow validation to pass straightly
         without adding relationship.
        */
        descriptionReport.viewed = true
        relationshipsReport.viewed = true

        descriptionReport.evaluator.addObserver(self)
        relationshipsReport.evaluator.addObserver(self)

    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.allValid) { [weak self] in
            return self?.reports.reduce(true) { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            } ?? false
        }
    }

    // Eval
    public override func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        self.evaluator.updateEvaluation(for: .allValid)
    }

    // Equatable
    public static func == (lhs: EventEntityDetailReport, rhs: EventEntityDetailReport) -> Bool {
        return lhs.entity == rhs.entity
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case descriptionReport
        case relationshipsReport
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        descriptionReport = try container.decode(EventEntityDescriptionReport.self, forKey: .descriptionReport)
        relationshipsReport = try container.decode(EventEntityRelationshipsReport.self, forKey: .relationshipsReport)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(descriptionReport, forKey: CodingKeys.descriptionReport)
        try container.encode(relationshipsReport, forKey: CodingKeys.relationshipsReport)
    }

}
