//
//  IncidentReport.swift
//  MPOLKit
//
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
    
    public var incidents: [Incident] = [] {
        didSet {
            event?.displayable?.title = incidents.isEmpty ? incidentsHeaderDefaultTitle : incidents.map{$0.displayable?.title}.joined(separator: ", ")
            event?.displayable?.subtitle = incidentsHeaderDefaultSubtitle
            evaluator.updateEvaluation(for: .incidents)
            delegate?.updateHeader(with: incidents.first?.displayable?.title, subtitle: nil)
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

    // Coding
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case incidents
    }

    public required init?(coder aDecoder: NSCoder) {
        incidents = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.incidents.rawValue) as! [Incident]
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(incidents, forKey: Coding.incidents.rawValue)
    }

    // Utility

    public func updateEval() {
        evaluator.updateEvaluation(for: [.incidents, .viewed])
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}

