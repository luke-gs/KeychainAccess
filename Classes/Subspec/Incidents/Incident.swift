//
//  Incidents.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Incident.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
final public class Incident: Codable, Evaluatable {

    public let id: UUID
    public var incidentType: IncidentType
    public var evaluator: Evaluator = Evaluator()

    public weak var event: Event?
    public weak var displayable: IncidentListDisplayable!

    private(set) public var reports: [Reportable] = [Reportable]() {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public init(event: Event, type: IncidentType) {
        self.event = event
        self.incidentType = type
        self.id = UUID()
        self.evaluator.registerKey(.allValid) {
            return !self.reports.map{$0.evaluator.isComplete}.contains(false)
        }
    }

    // Codable stuff begins

    public init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        reports = try container.decode([Reportable].self, forKey: .reports)
        id = try container.decode(UUID.self, forKey: .id)
        incidentType = IncidentType(rawValue: try container.decode(String.self, forKey: .incidentType))
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(reports, forKey: .reports)
        try container.encode(id, forKey: .id)
        try container.encode(incidentType.rawValue, forKey: .incidentType)
    }

    enum Keys: String, CodingKey {
        case reports
        case id
        case incidentType
    }

    //MARK: Utility

    public func add(reports: [Reportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: Reportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> Reportable? {
        return reports.filter{type(of: $0) == reportableType}.first
    }

    //MARK: Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        allValid = evaluationState
    }
}

/// A bunch of incident types
/// This can later be expanded upon to build different types of events
/// via the app
public struct IncidentType: RawRepresentable, Hashable {

    //Define default EventTypes
    public static let blank = IncidentType(rawValue: "Blank")

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public static func ==(lhs: IncidentType, rhs: IncidentType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

/// Builder for incidents
///
/// Used to define what an incident should look like for a specific incident type
/// in terms of the reports it should have
public protocol IncidentBuilding {

    /// Create an event, injecting any reports that you need.
    ///
    /// - Parameter type: the type of event that is being asked to be created.
    /// - Returns: a tuple of an event and it's list view representation
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
    /// - Parameter reportables: the array of reports to construct view controllers for
    /// - Returns: an array of viewController constucted for the reports
    func viewControllers(for reportables: [Reportable]) -> [UIViewController]
}

