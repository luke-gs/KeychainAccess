//
//  Incidents.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Unbox
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Incident.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
public class Incident: IdentifiableDataModel, Evaluatable {

    // MARK: - Properties

    /// The title to display for the incident
    public var title: String?

    /// The incident type
    public var incidentType: IncidentType

    /// The nested additional actions
    public var actions: [AdditionalAction] = [] {
        didSet {
            configureChildren()
        }
    }

    /// The nested reports
    private(set) public var reports: [IncidentReportable] = [] {
        didSet {
            configureChildren()
        }
    }

    /// The storage for relationships between entities and additional actions
    public let relationshipManager = RelationshipManager<MPOLKitEntity, AdditionalAction>()

    // MARK: - State

    public var evaluator: Evaluator = Evaluator()

    public var weakEvent: Weak<Event> {
        didSet {
            configureChildren()
        }
    }

    // MARK: - Init

    public init(event: Event, type: IncidentType) {
        self.weakEvent = Weak(event)
        self.incidentType = type
        self.title = type.rawValue

        super.init(id: UUID().uuidString)
        commonInit()

        // Configure children, since we have the event
        configureChildren()
    }

    private func commonInit() {
        self.evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return self.reportsValid && self.actionsValid
        }
    }

    /// Update child reports and actions if we have our parent event
    private func configureChildren() {
        // Should only be called after our Event back ref is set
        guard weakEvent.object != nil else { return }

        // Pass down the incident to child reports and actions
        for report in reports {
            if report.weakIncident.object == nil {
                report.weakIncident = Weak<Incident>(self)
            }
        }
        for action in actions {
            if action.weakIncident.object == nil {
                action.weakIncident = Weak<Incident>(self)
            }
        }
        // Update our valid state based on current children
        evaluator.updateEvaluation(for: .allValid)
    }

    // MARK: - Utility

    public func add(reports: [IncidentReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: IncidentReportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> IncidentReportable? {
        return reports.filter {type(of: $0) == reportableType}.first
    }

    // MARK: - Evaluation

    private var reportsValid: Bool {
        return reports.reduce(true, { result, report in
            return result && report.evaluator.isComplete
        })
    }

    public var actionsValid: Bool {
        return actions.reduce(true, { (_, action) -> Bool in
            return action.evaluator.isComplete
        })
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        // Update our evaluator if any evaluator we are observing changes
        self.evaluator.updateEvaluation(for: .allValid)
    }

    // MARK: - Codable

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    private enum CodingKeys: String, CodingKey {
        case actions
        case incidentType
        case relationships
        case reports
        case title
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        actions = try container.decode([AdditionalAction].self, forKey: .actions)
        incidentType = try container.decode(IncidentType.self, forKey: .incidentType)
        title = try container.decode(String.self, forKey: .title)
        relationshipManager.add(try container.decode([Relationship].self, forKey: .relationships))

        let anyReports = try container.decode([AnyIncidentReportable].self, forKey: .reports)
        reports = anyReports.map { $0.report }

        /// Set to nil initially, until parent passes it to us during it's decode
        weakEvent = Weak<Event>(nil)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        // Convert our array of protocols to concrete classes, for Codable
        let anyReports = reports.map { return AnyIncidentReportable($0) }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
        try container.encode(incidentType, forKey: .incidentType)
        try container.encode(title, forKey: .title)
        try container.encode(relationshipManager.relationships, forKey: .relationships)
        try container.encode(anyReports, forKey: .reports)
    }

    // MARK: - Equatable

    public static func == (lhs: Incident, rhs: Incident) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A bunch of incident types
/// This can later be expanded upon to build different types of events
/// via the app
public class IncidentType: ExtensibleKey<String>, Codable {

    //Define default EventTypes
    public static let blank = IncidentType("Blank")
}

/// Builder for incidents
///
/// Used to define what an incident should look like for a specific incident type
/// in terms of the reports it should have
public protocol IncidentBuilding {

    /// Create an incident, injecting any reports that you need.
    /// Note: this does not add the new incident to the event
    ///
    /// - Parameter type: The type of event that is being asked to be created.
    /// - Returns: The new incident
    func createIncident(for type: IncidentType, in event: Event) -> Incident

    /// Create a displayable for an incident, to be shown in incident list
    ///
    /// - Parameter incident: The incident
    /// - Returns: The list displayable
    func displayable(for incident: Incident) -> IncidentListDisplayable

}

/// Screen builder for the incident
///
/// Used to provide a viewcontroller for the reportables
///
/// Can be used to provide different view controllers for OOTB reports
/// - ie. DateTimeReport
public protocol IncidentScreenBuilding {

    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: The array of reports to construct view controllers for
    /// - Returns: An array of viewController constucted for the reports
    func viewControllers(for reportables: [IncidentReportable]) -> [UIViewController]
}
