//
//  PersonSearchReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class PersonSearchReport: Reportable {

    public var event: Event?
    public var incident: Incident?
    public let evaluator: Evaluator = Evaluator()

    init(event: Event?, incident: Incident?) {

        self.event = event
        self.incident = incident

        if let event = self.event {
            evaluator.addObserver(event)
        }
        if let incident = self.incident {
            evaluator.addObserver(incident)
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
