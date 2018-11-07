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

    // Uuid of the entity
    public var entityUuid: String

    /// Return the entity from the event
    public var entity: MPOLKitEntity? {
        return event?.entities[entityUuid]
    }

    public var relationships: [Relationship<MPOLKitEntity, MPOLKitEntity>]? {
        return event?.entityManager.entityRelationships
    }

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public init(event: Event, entity: MPOLKitEntity) {
        entityUuid = entity.uuid
        super.init(event: event)
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case entityUuid
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entityUuid = try container.decode(String.self, forKey: .entityUuid)
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entityUuid, forKey: CodingKeys.entityUuid)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

}
