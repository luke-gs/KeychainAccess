//
//  Event.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Event.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
final public class Event: Codable, Evaluatable {

    private(set) public var reports: [Reportable] = [Reportable]()
    public var evaluator: Evaluator = Evaluator()

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public init() {
        evaluator.registerKey(.allValid) {
            return !self.reports.map{$0.evaluator.isComplete}.contains(false)
        }
    }

    // Codable stuff begins

    public init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        reports = try container.decode([Reportable].self, forKey: .reports)
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(reports, forKey: .reports)
    }

    enum Keys: String, CodingKey {
        case reports = "reports"
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

/// A bunch of event types
/// This can later be expanded upon to build different types of events
/// via the app
public struct EventType: RawRepresentable, Hashable {

    //Define default EventTypes
    static let blank = EventType(rawValue: "blank")

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public static func ==(lhs: EventType, rhs: EventType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

/// Anything can be reportable
/// Used to define something in the event object
public protocol Reportable: Codable, Evaluatable {

    /// A weak reference to the event object
    /// Make sure this is weak in implementation as well
    weak var event: Event? { get set }

    /// Required initializer for a reportable
    ///
    /// - Parameter event: the event
    init(event: Event)
}

/// Builder for event
///
/// Used to define what an event should look like for a specific event type
/// in terms of the reports it should have
public protocol EventBuilding {

    /// Create an event, injecting any reports that you need.
    ///
    /// - Parameter type: the type of event that is being asked to be created.
    /// - Returns: a tuple of an event and it's list view representation
    func createEvent(for type: EventType) -> (event: Event, displayable: EventListDisplayable)
}

/// Screen builder for the event
///
/// Used to provide a viewcontroller for the reportables
///
/// Can be used to provide different view controllers for OOTB reports
/// - ie. DateTimeReport
public protocol EventScreenBuilding {

    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: the array of reports to construct view controllers for
    /// - Returns: an array of viewController constucted for the reports
    func viewControllers(for reportables: [Reportable]) -> [UIViewController]
}
