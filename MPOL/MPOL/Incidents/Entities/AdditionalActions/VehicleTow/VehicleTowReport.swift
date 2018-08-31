//
//  VehicleTowReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit
import ClientKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

public class VehicleTowReport: ActionReportable, MediaContainer {
    
    public let weakAdditionalAction: Weak<AdditionalAction>
    public let weakIncident: Weak<Incident>

    public let evaluator: Evaluator = Evaluator()

    var location: EventLocation? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    var towReason: String?
    var authorisingOfficer: Officer?
    var notifyingOfficer: Officer?
    var date: Date?
    var hold: Bool? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    var holdReason: String?
    var holdRemarks: String?
    public var media: [MediaAsset] = []

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
            return self.location != nil
                && self.hold != nil
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

    // Media Container
    public func add(_ media: [MediaAsset]) {
        media.forEach {
            if !self.media.contains($0) {
                self.media.append($0)
            }
        }
    }

    public func remove(_ media: [MediaAsset]) {
        media.forEach { asset in
            if let index = self.media.index(where: { $0 == asset }) {
                self.media.remove(at: index)
            }
        }
    }
}

extension AdditionalActionType {
    public static let vehicleTow = AdditionalActionType(rawValue: "Vehicle Tow Report")
}
