//
//  AdditionalAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Unbox

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Additional Action.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
public class AdditionalAction: IdentifiableDataModel, Evaluatable {

    public var additionalActionType: AdditionalActionType
    public var evaluator: Evaluator = Evaluator()

    public var weakIncident: Weak<Incident> {
        didSet {
            updateReportsWithIncident()
        }
    }

    private(set) public var reports: [AnyIncidentReportable] = [] {
        didSet {
            updateReportsWithIncident()
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
        super.init(id: UUID().uuidString)

        self.evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
    }

    private func updateReportsWithIncident() {
        // Pass down the incident
        for report in reports {
            report.weakIncident = weakIncident
        }
    }

    // MARK: - Codable

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    private enum CodingKeys: String, CodingKey {
        case additionalActionType
        case reports
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalActionType = try container.decode(AdditionalActionType.self, forKey: .additionalActionType)
        reports = try container.decode([AnyIncidentReportable].self, forKey: .reports)
        weakIncident = Weak<Incident>(nil)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalActionType, forKey: CodingKeys.additionalActionType)
        try container.encode(reports, forKey: CodingKeys.reports)
    }

    // MARK: Utility

    public func add(reports: [IncidentReportable]) {
        self.reports.append(contentsOf: reports.map { return AnyIncidentReportable($0) })
    }

    public func add(report: IncidentReportable) {
        reports.append(AnyIncidentReportable(report))
    }

    public func reportable(atIndex index: Int) -> IncidentReportable? {
        return reports[index].report
    }

    // MARK: Evaluation

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
public class AdditionalActionType: ExtensibleKey<String>, Codable { }

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
