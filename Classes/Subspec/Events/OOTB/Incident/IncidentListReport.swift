//
//  IncidentReport.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
    static let incidents = EvaluatorKey("incidents")
}

open class IncidentListReport: Reportable {

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public weak var event: Event?

    private(set) public var evaluator: Evaluator = Evaluator()
    public var incidents: [String] = [] {
        didSet {
            evaluator.updateEvaluation(for: .incidents)
        }
    }

    public required init(event: Event) {
        self.event = event

        evaluator.addObserver(event)
        evaluator.registerKey(.viewed) {
            return self.viewed
        }
        evaluator.registerKey(.incidents) {
            return self.incidents.count > 0
        }
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        incidents = try container.decode([String].self, forKey: .incidents)
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(incidents, forKey: .incidents)
    }

    enum Keys: String, CodingKey {
        case incidents = "incidents"
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

