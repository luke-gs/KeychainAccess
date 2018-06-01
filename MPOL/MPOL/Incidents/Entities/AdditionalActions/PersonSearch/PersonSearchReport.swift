//
//  PersonSearchReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class PersonSearchReport: ActionReportable {

    public private(set) weak var event: Event?
    public private(set) weak var incident: Incident?
    public private(set) weak var additionalAction: AdditionalAction?

    public let evaluator: Evaluator = Evaluator()

    public var viewed = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }


    public init(incident: Incident?, additionalAction: AdditionalAction) {

        self.incident = incident
        self.additionalAction = additionalAction

        if let incident = self.incident {
            evaluator.addObserver(incident)
        }
        if let additionalAction = self.additionalAction {
            evaluator.addObserver(additionalAction)
        }

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
    }

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}

extension AdditionalActionType {
    public static let personSearch = AdditionalActionType(rawValue: "Person Search Report")
}
