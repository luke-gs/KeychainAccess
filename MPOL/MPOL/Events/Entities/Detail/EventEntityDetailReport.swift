//
//  EventEntityDetailReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let descriptionViewed = EvaluatorKey("descriptionViewed")
    static let relationshipViewed = EvaluatorKey("relationshipViewed")
}

public class EventEntityDetailReport: Reportable {

    public weak var event: Event?
    public weak var incident: Incident?
    public unowned var entity: MPOLKitEntity

    public var evaluator: Evaluator = Evaluator()

    var descriptionViewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .descriptionViewed)
        }
    }

    var relationshipViewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .relationshipViewed)
        }
    }

    public init(entity: MPOLKitEntity, event: Event?) {
        self.event = event
        self.entity = entity

        evaluator.registerKey(.descriptionViewed) {
            return self.descriptionViewed
        }

        evaluator.registerKey(.relationshipViewed) {
            return self.relationshipViewed
        }
    }

    //Coding
    public static var supportsSecureCoding: Bool = true
    public func encode(with aCoder: NSCoder) { }
    required public init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }

    //Eval
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

    //Equatable
    public static func == (lhs: EventEntityDetailReport, rhs: EventEntityDetailReport) -> Bool {
        return lhs.entity == rhs.entity
    }
}
