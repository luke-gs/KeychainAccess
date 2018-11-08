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
            updateChildReports()
        }
    }

    private(set) public var reports: [ActionReportable] = [] {
        didSet {
            updateChildReports()
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
        commonInit()
    }

    private func commonInit() {
        self.evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
        updateChildReports()
    }

    private func updateChildReports() {
        // Pass down this incident and parent event to child reports
        for report in reports {
            report.weakAdditionalAction = Weak(self)
            report.weakIncident = weakIncident
            if let report = report as? EventReportable, let weakEvent = weakIncident.object?.weakEvent {
                report.weakEvent = weakEvent
            }
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

        let anyReports = try container.decode([AnyIncidentReportable].self, forKey: .reports)
        reports = anyReports.compactMap { $0.report as? ActionReportable }

        /// Set to nil initially, until parent passes it to us during it's decode
        weakIncident = Weak<Incident>(nil)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        // Convert our array of protocols to concrete classes, for Codable
        let anyReports = reports.map { return AnyIncidentReportable($0) }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalActionType, forKey: CodingKeys.additionalActionType)
        try container.encode(anyReports, forKey: CodingKeys.reports)
    }

    // MARK: Utility

    public func add(reports: [ActionReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: ActionReportable) {
        reports.append(report)
    }

    public func reportable(atIndex index: Int) -> ActionReportable? {
        return reports[index]
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
    func viewControllers(for reports: [ActionReportable]) -> [UIViewController]
}
