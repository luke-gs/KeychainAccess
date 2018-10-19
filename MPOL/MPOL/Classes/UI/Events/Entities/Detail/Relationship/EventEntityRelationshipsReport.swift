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

public class EventEntityRelationshipsReport: EventReportable {
    public let weakEvent: Weak<Event>

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
        self.weakEvent = Weak(event)
        self.entity = entity
        
        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: Eval
    public var evaluator: Evaluator = Evaluator()
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: Coding
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    public func encode(with aCoder: NSCoder) {

    }
}
