//
//  IncidentReport.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
    static let incidents = EvaluatorKey("incidents")
}

open class IncidentListReport: Reportable, EventHeaderUpdateable {

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }
    
    public var incidents: [Incident] = []
    public var incidentDisplayables: [IncidentListDisplayable] = []{
        didSet {
            evaluator.updateEvaluation(for: .incidents)
            delegate?.updateHeader(with: incidentDisplayables.first?.title, subtitle: nil)
        }
    }

    public weak var delegate: EventHeaderUpdateDelegate?
    private(set) public var evaluator: Evaluator = Evaluator()
    public weak var event: Event?
    public weak var incident: Incident?

    public required init(event: Event, incident: Incident? = nil) {
        self.event = event
        self.incident = incident
        commonInit()
    }

    private func commonInit() {
        if let event = event { evaluator.addObserver(event) }
        if let incident = incident { evaluator.addObserver(incident) }

        evaluator.registerKey(.viewed) { return self.viewed }
        evaluator.registerKey(.incidents) {
            let eval = self.incidents.reduce(true, { (result, incident) -> Bool in
                return result && incident.evaluator.isComplete
            })
            return self.incidents.count > 0 && eval
        }
    }

    // Utility

    public func updateEval() {
        evaluator.updateEvaluation(for: [.incidents, .viewed])
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        incidents = try container.decode([Incident].self, forKey: .incidents)
        commonInit()
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

