//
//  VehicleTowReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

public class VehicleTowReport: ActionReportable {
    
    public let weakAdditionalAction: Weak<AdditionalAction>
    public let weakIncident: Weak<Incident>

    public let evaluator: Evaluator = Evaluator()

    public var viewed = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public init(incident: Incident?, additionalAction: AdditionalAction) {

        self.weakIncident = Weak(incident)
        self.weakAdditionalAction = Weak(additionalAction)

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
    private enum Coding: String {
        case incident
        case action
    }

    public static var supportsSecureCoding: Bool = true

    public required init?(coder aDecoder: NSCoder) {
        weakAdditionalAction = aDecoder.decodeWeakObject(forKey: Coding.action.rawValue)
        weakIncident = aDecoder.decodeWeakObject(forKey: Coding.incident.rawValue)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encodeWeakObject(weakObject: weakAdditionalAction, forKey: Coding.action.rawValue)
        aCoder.encodeWeakObject(weakObject: weakIncident, forKey: Coding.incident.rawValue)
    }
}

extension AdditionalActionType {
    public static let vehicleTow = AdditionalActionType(rawValue: "Vehicle Tow Report")
}

