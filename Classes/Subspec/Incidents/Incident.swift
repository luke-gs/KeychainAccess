//
//  Incidents.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Incident.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
final public class Incident: NSSecureCoding, Evaluatable, Equatable {

    public let id: String
    public var incidentType: IncidentType
    public var evaluator: Evaluator = Evaluator()
    public let additionalActionManager = AdditionalActionManager()

    public let weakEvent: Weak<Event>
    public weak var displayable: IncidentListDisplayable!

    private(set) public var reports: [IncidentReportable] = [IncidentReportable]() {
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
        self.weakEvent = Weak(event)
        self.incidentType = type
        self.id = UUID().uuidString
        self.evaluator.registerKey(.allValid) {
            return !self.reports.map{$0.evaluator.isComplete}.contains(false)
        }
    }

    // Coding stuff begins

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case id
        case incidentType
        case reports
        case event
    }

    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
        incidentType = IncidentType(rawValue: aDecoder.decodeObject(of: NSString.self, forKey: Coding.incidentType.rawValue)! as String)
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.reports.rawValue) as! [IncidentReportable]
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(incidentType.rawValue, forKey: Coding.incidentType.rawValue)
        aCoder.encode(reports, forKey: Coding.reports.rawValue)
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
    }

    //MARK: Utility

    public func add(reports: [IncidentReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: IncidentReportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> IncidentReportable? {
        return reports.filter{type(of: $0) == reportableType}.first
    }

    //MARK: Evaluation

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
    func viewControllers(for reportables: [IncidentReportable]) -> [UIViewController]
}

