//
//  Event.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 16/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// Anything can be reportable
/// Used to define something in the event object
public protocol Reportable: NSCoding, Evaluatable {
    weak var event: Event? { get set }
    init(event: Event)
}

//TODO: Make this something else that is extensible by the app
public enum EventType {
    case blank
}

/// The implementation of an Event.
/// All it really is, is an array of reports
final public class Event: NSCoding, Evaluatable {

    private(set) public var reports: [Reportable] = [Reportable]()
    public var evaluator: Evaluator = Evaluator()

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(reports, forKey: "reports")
    }

    public init?(coder aDecoder: NSCoder) {
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: "reports") as! [Reportable]
        evaluator = aDecoder.decodeObject(forKey: "evaluator") as! Evaluator
    }

    public init() {
        evaluator.registerKey(.allValid) {
            return !self.reports.map{$0.evaluator.isComplete}.contains(false)
        }
    }

    public func add(reports: [Reportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: Reportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> Reportable? {
        return reports.filter{type(of: $0) == reportableType}.first
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        allValid = evaluationState
    }
}

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}


/// Builder for event
///
/// Used to define what an event should look like for a specific event type
public protocol EventBuilding: NSCoding {

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
public protocol EventScreenBuilding: NSCoding {

    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: the array of reports to construct view controllers for
    /// - Returns: an array of viewController constucted for the reports
    func viewControllers(for reportables: [Reportable]) -> [UIViewController]
}
