//
//  EventEntityDescriptionReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class EventEntityDescriptionReport: DefaultEventReportable {

    // Uuid of the entity
    public var entityUuid: String

    /// Return the entity from the event
    public var entity: MPOLKitEntity? {
        return event?.entityBucket.entity(for: entityUuid)
    }

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public init(event: Event, entity: MPOLKitEntity) {
        entityUuid = entity.uuid
        super.init(event: event)
        commonInit()
    }

    private func commonInit() {
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
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entityUuid, forKey: CodingKeys.entityUuid)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

}
