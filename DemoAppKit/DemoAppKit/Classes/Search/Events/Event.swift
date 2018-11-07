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

    private(set) public var reports: [EventReportable] = [] {
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

    public init() {
        super.init(id: UUID().uuidString)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
        updateChildReports()
    }

    private func updateChildReports() {
        // Pass down this event to child reports
        for report in reports {
            report.weakEvent = Weak<Event>(self)
        }
    }

    // MARK: Utility

    public func add(reports: [EventReportable]) {
        self.reports.append(contentsOf: reports)
    }

    public func add(report: EventReportable) {
        reports.append(report)
    }

    public func reportable(for reportableType: AnyClass) -> EventReportable? {
        return reports.filter {type(of: $0) == reportableType}.first
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
        let anyReports = try container.decode([AnyEventReportable].self, forKey: .reports)

        reports = anyReports.map { $0.report }

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        // Convert our array of protocols to concrete classes, for Codable
        let anyReports = reports.map { return AnyEventReportable($0) }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(anyReports, forKey: CodingKeys.reports)
    }

    open func writeFile() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: URL(fileURLWithPath: "/Users/trent/Documents/event.json"))
        } catch let error {
            print(error)
        }
    }

}
