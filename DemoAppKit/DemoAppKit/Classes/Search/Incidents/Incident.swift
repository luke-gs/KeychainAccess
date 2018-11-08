//
//  Incidents.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Unbox

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Incident.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
public class Incident: IdentifiableDataModel, Evaluatable {

    // MARK: - Properties

    /// The incident type
    public var incidentType: IncidentType

    /// The nested additional actions
    public var actions: [AdditionalAction] = []

    /// The properties used for display in list
    public var displayable: IncidentListDisplayable!

    /// The nested reports
    private(set) public var reports: [IncidentReportable] = [] {
        didSet {
            updateChildReports()
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    // MARK: - State

    public var additionalActionManager: AdditionalActionManager!

    public var evaluator: Evaluator = Evaluator()

    public var weakEvent: Weak<Event> {
        didSet {
            updateChildReports()
        }
    }

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    // MARK: - Init

    public init(event: Event, type: IncidentType) {
        self.weakEvent = Weak(event)
        self.incidentType = type
        super.init(id: UUID().uuidString)
        commonInit()
    }

    private func commonInit() {
        self.additionalActionManager = AdditionalActionManager(incident: self)

        self.evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
        updateChildReports()
    }

    private func updateChildReports() {
        // Pass down this incident and parent event to child reports and actions
        for report in reports {
            report.weakIncident = Weak<Incident>(self)
            if let report = report as? EventReportable {
                report.weakEvent = weakEvent
            }
        }
        for action in actions {
            action.weakIncident = Weak<Incident>(self)
        }
    }

    // MARK: - Codable

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    private enum CodingKeys: String, CodingKey {
        case actions
        case displayable
        case incidentType
        case reports
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actions = try container.decode([AdditionalAction].self, forKey: .actions)
        displayable = try container.decode(IncidentListDisplayable.self, forKey: .displayable)
        incidentType = try container.decode(IncidentType.self, forKey: .incidentType)

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
        try container.encode(displayable, forKey: .displayable)
        try container.encode(incidentType, forKey: .incidentType)
        try container.encode(anyReports, forKey: .reports)
    }

    // MARK: Utility

    public func add(reports: [IncidentReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: IncidentReportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> IncidentReportable? {
        return reports.filter {type(of: $0) == reportableType}.first
    }

    // MARK: Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        allValid = reports.reduce(true, { result, report in
            return result && report.evaluator.isComplete
        })
    }

    // MARK: Equatable
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

    /// Create an event, injecting any reports that you need.
    ///
    /// - Parameter type: The type of event that is being asked to be created.
    /// - Returns: A tuple of an event and it's list view representation
    func createIncident(for type: IncidentType, in event: Event) -> (incident: Incident, displayable: IncidentListDisplayable)
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
