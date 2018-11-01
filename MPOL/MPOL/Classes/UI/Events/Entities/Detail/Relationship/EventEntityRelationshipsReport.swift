//
//  EventEntityRelationshipsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class EventEntityRelationshipsReport: DefaultEventReportable {

    // TODO: persist entity id
    public weak var entity: MPOLKitEntity?

    public var relationships: [Relationship<MPOLKitEntity, MPOLKitEntity>]? {
        return event?.entityManager.entityRelationships
    }

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public init(event: Event, entity: MPOLKitEntity) {
        self.entity = entity
        super.init(event: event)
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

}
