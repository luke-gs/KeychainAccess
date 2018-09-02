//
//  PersonSearchReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit
import DemoAppKit
import ClientKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

public class PersonSearchReport: ActionReportable {
    public let weakAdditionalAction: Weak<AdditionalAction>
    public let weakIncident: Weak<Incident>

    public let evaluator: Evaluator = Evaluator()

    public var searchType: String?
    public var detainedStart: Date? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var detainedEnd: Date?
    public var searchStart: Date? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var searchEnd: Date?
    public var location: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var officers = [Officer]() {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var legalPower: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var searchReason: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var outcome: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var clothingRemoved: Bool? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var remarks: String?

    public init(incident: Incident?, additionalAction: AdditionalAction) {
        self.weakIncident = Weak(incident)
        self.weakAdditionalAction = Weak(additionalAction)

        if let incident = self.incident {
            evaluator.addObserver(incident)
        }
        if let additionalAction = self.additionalAction {
            evaluator.addObserver(additionalAction)
        }

        evaluator.registerKey(.hasRequiredData) {

            return self.detainedStart != nil && self.searchStart != nil
                && self.location != nil && !self.officers.isEmpty
                && self.legalPower != nil && self.searchReason != nil
                && self.outcome != nil && self.clothingRemoved != nil
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
    public static let personSearch = AdditionalActionType(rawValue: "Person Search Report")
}

