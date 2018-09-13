//
//  AdditionalAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Additional Action.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
final public class AdditionalAction: NSSecureCoding, Evaluatable, Equatable {

    public let id: String
    public var additionalActionType: AdditionalActionType
    public var evaluator: Evaluator = Evaluator()

    public let weakIncident: Weak<Incident>

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

    public init(incident: Incident, type: AdditionalActionType) {
        self.weakIncident = Weak(incident)
        self.additionalActionType = type
        self.id = UUID().uuidString
        self.evaluator.registerKey(.allValid) {
            return !self.reports.map{$0.evaluator.isComplete}.contains(false)
        }
    }

    // Coding stuff begins

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case id
        case additionalActionType
        case reports
        case incident
    }


    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
        additionalActionType = AdditionalActionType(rawValue: aDecoder.decodeObject(of: NSString.self, forKey: Coding.additionalActionType.rawValue)! as String)
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.reports.rawValue) as! [IncidentReportable]
        weakIncident = aDecoder.decodeWeakObject(forKey: Coding.incident.rawValue)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(additionalActionType.rawValue, forKey: Coding.additionalActionType.rawValue)
        aCoder.encode(reports, forKey: Coding.reports.rawValue)
        aCoder.encodeWeakObject(weakObject: weakIncident, forKey: Coding.incident.rawValue)
    }

    //MARK: Utility

    public func add(reports: [IncidentReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: IncidentReportable) {
        reports.append(report)
    }

    public func reportable(atIndex index: Int) -> IncidentReportable? {
        return reports[index]
    }

    //MARK: Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        allValid = reports.reduce(true, { result, report in
            return result && report.evaluator.isComplete
        })
    }

    // MARK: Equatable
    public static func == (lhs: AdditionalAction, rhs: AdditionalAction) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A bunch of Additional Actions
/// This can later be expanded upon to build different types of incidents/ events
/// via the app
public class AdditionalActionType: ExtensibleKey<String> { }

/// Builder for additional action
///
/// Used to define what an additional action should look like for a specific incident type
/// in terms of the reports it should have
public protocol AdditionalActionBuilding {

    /// Create an additional action, injecting any reports that you need.
    ///
    /// - Parameter type: The type of additional action that is being asked to be created.
    func createAdditionalAction(for type: AdditionalActionType, on incident: Incident) -> AdditionalAction
}

/// Screen builder for the additional action
///
/// Used to provide a viewcontroller for the reportables
public protocol AdditionalActionScreenBuilding {

    /// Constructs an array of view controllers depending on what reportables are passed in
    ///
    /// - Parameter reportables: The array of reports to construct view controllers for
    /// - Returns: An array of viewController constucted for the reports
    func viewControllers(for reports: [IncidentReportable]) -> [UIViewController] 
}



