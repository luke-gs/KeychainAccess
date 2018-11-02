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

    public var incidentType: IncidentType
    public var evaluator: Evaluator = Evaluator()
    public let additionalActionManager = AdditionalActionManager()

    public let weakEvent: Weak<Event>
    public var displayable: IncidentListDisplayable!

    private(set) public var reports: [IncidentReportable] = [] {
        didSet {
            // Pass down the incident and event
            for report in reports {
                report.weakIncident = Weak<Incident>(self)
                if let report = report as? EventReportable {
                    report.weakEvent = weakEvent
                }
            }
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public init(event: Event, type: IncidentType) {
        self.weakEvent = Weak(event)
        self.incidentType = type
        super.init(id: UUID().uuidString)
        commonInit()
    }

    private func commonInit() {
        self.evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
    }

    // MARK: - Codable

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    private enum CodingKeys: String, CodingKey {
        case incidentType
        case reports
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        incidentType = try container.decode(IncidentType.self, forKey: .incidentType)

        let anyReports = try container.decode([AnyIncidentReportable].self, forKey: .reports)
        reports = anyReports.map { $0.report }

        weakEvent = Weak<Event>(nil)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        // Convert our array of protocols to concrete classes, for Codable
        let anyReports = reports.map { return AnyIncidentReportable($0) }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(incidentType, forKey: CodingKeys.incidentType)
        try container.encode(anyReports, forKey: CodingKeys.reports)
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
