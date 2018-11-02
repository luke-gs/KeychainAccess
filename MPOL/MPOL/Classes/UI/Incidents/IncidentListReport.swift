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

open class IncidentListReport: DefaultEventReportable, SideBarHeaderUpdateable {

    public var viewed: Bool = false {
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

    public override init(event: Event) {
        super.init(event: event)
    }

    open override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
        evaluator.registerKey(.incidents) { [weak self] in
            guard let `self` = self else { return false }
            let eval = self.incidents.reduce(true, { (result, incident) -> Bool in
                return result && incident.evaluator.isComplete
            })
            return self.incidents.count > 0 && eval
        }
    }

    // MARK: - Utility

    public func updateEval() {
        evaluator.updateEvaluation(for: [.incidents, .viewed])
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case incidents
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        incidents = try container.decode([Incident].self, forKey: .incidents)
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(incidents, forKey: CodingKeys.incidents)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

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
