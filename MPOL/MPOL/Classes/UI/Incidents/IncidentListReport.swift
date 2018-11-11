//
//  IncidentReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
    static let incidents = EvaluatorKey("incidents")
}

/// Provide access to incident relationships to top level event object
/// This is pretty hacky, but Event has no direct coupling to Incident
extension Event {
    public var incidentListReport: IncidentListReport? {
        return self.reports.compactMap { $0 as? IncidentListReport }.first
    }

    public var incidentRelationshipManager: RelationshipManager<MPOLKitEntity, Incident>? {
        return incidentListReport?.relationshipManager
    }
}

open class IncidentListReport: DefaultEventReportable, SideBarHeaderUpdateable {

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public var incidents: [Incident] = [] {
        didSet {
            event?.title = incidents.isEmpty ? nil : incidents.map { $0.title }.joined(separator: ", ")
            evaluator.updateEvaluation(for: .incidents)
            delegate?.updateHeader(with: incidents.first?.title, subtitle: nil)
        }
    }

    /// The manager and storage for relationships between entities and child incidents
    public let relationshipManager = RelationshipManager<MPOLKitEntity, Incident>()

    public weak var delegate: SideBarHeaderUpdateDelegate?

    public override init(event: Event) {
        super.init(event: event)
    }

    open override func configure(with event: Event) {
        super.configure(with: event)

        // Pass on the event to child incidents
        for incident in incidents {
            incident.weakEvent = Weak(event)
        }

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
        case relationships
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        incidents = try container.decode([Incident].self, forKey: .incidents)
        relationshipManager.add(try container.decode([Relationship].self, forKey: .relationships))
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(incidents, forKey: CodingKeys.incidents)
        try container.encode(relationshipManager.relationships, forKey: .relationships)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

}

extension IncidentListReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        incidents.forEach { (incident) in
            items.append(LargeTextHeaderFormItem(text: incident.title))
            incident.reports.forEach({ (report) in
                if let report = report as? Summarisable {
                    items += report.formItems
                }
            })
        }
        return items
    }
}
