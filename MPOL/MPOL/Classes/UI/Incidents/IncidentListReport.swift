//
//  IncidentReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
    static let incidents = EvaluatorKey("incidents")
}

open class IncidentListReport: EventReportable, SideBarHeaderUpdateable {
    public let weakEvent: Weak<Event>

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public var incidents: [Incident] = [] {
        didSet {
            event?.displayable?.title = incidents.isEmpty ? incidentsHeaderDefaultTitle : incidents.map { $0.displayable?.title }.joined(separator: ", ")
            event?.displayable?.subtitle = incidentsHeaderDefaultSubtitle
            evaluator.updateEvaluation(for: .incidents)
            delegate?.updateHeader(with: incidents.first?.displayable?.title, subtitle: nil)
        }
    }

    public weak var delegate: SideBarHeaderUpdateDelegate?
    private(set) public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.weakEvent = Weak(event)
        commonInit()
    }

    private func commonInit() {
        if let event = event {
            evaluator.addObserver(event)
        }

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
        evaluator.registerKey(.incidents) {
            let eval = self.incidents.reduce(true, { (result, incident) -> Bool in
                return result && incident.evaluator.isComplete
            })
            return self.incidents.count > 0 && eval
        }
    }

    // MARK: - Coding
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case incidents
        case event
    }

    public required init?(coder aDecoder: NSCoder) {
        incidents = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.incidents.rawValue) as! [Incident]
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        commonInit()
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(incidents, forKey: Coding.incidents.rawValue)
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
    }

    // MARK: - Utility

    public func updateEval() {
        evaluator.updateEvaluation(for: [.incidents, .viewed])
    }

    // MARK: - Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}
}

extension IncidentListReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        incidents.forEach { (incident) in
            items.append(LargeTextHeaderFormItem(text: incident.displayable.title))
            incident.reports.forEach({ (report) in
                if let report = report as? Summarisable {
                    items += report.formItems
                }
            })
        }
        return items
    }
}
