//
//  Event.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import Unbox
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Event.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
public class Event: IdentifiableDataModel, Evaluatable {

    public var evaluator: Evaluator = Evaluator()
    public weak var displayable: EventListDisplayable?
    public let entityManager = EventEntityManager()

    private(set) public var reports: [AnyEventReportable] = [] {
        didSet {
            // Pass down the event
            for report in reports {
                report.weakEvent = Weak<Event>(self)
            }
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public init() {
        super.init(id: UUID().uuidString)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
    }

    // MARK: Utility

    public func add(reports: [EventReportable]) {
        self.reports.append(contentsOf: reports.map { return AnyEventReportable($0) })
    }

    public func add(report: EventReportable) {
        reports.append(AnyEventReportable(report))
    }

    public func reportable(for reportableType: AnyClass) -> EventReportable? {
        return reports.filter {type(of: $0) == reportableType}.first?.report
    }

    // MARK: Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        allValid = reports.reduce(true, { result, report in
            return result && report.evaluator.isComplete
        })
    }

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case reports
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reports = try container.decode([AnyEventReportable].self, forKey: .reports)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reports, forKey: CodingKeys.reports)
    }

}
