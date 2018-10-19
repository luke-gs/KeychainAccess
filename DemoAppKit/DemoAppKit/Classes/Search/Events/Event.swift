//
//  Event.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

fileprivate extension EvaluatorKey {
    static let allValid = EvaluatorKey(rawValue: "allValid")
}

/// The implementation of an Event.
/// All it really is, is an array of reports with some basic business logic
/// to check if all reports are valid through the evaluator
final public class Event: NSObject, NSSecureCoding, Evaluatable {

    public let id: String
    public var evaluator: Evaluator = Evaluator()
    public weak var displayable: EventListDisplayable?
    public let entityManager = EventEntityManager()

    private(set) public var reports: [EventReportable] = [EventReportable]() {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    private var allValid: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    public override init() {
        id = UUID().uuidString
        super.init()
        evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return !self.reports.map {$0.evaluator.isComplete}.contains(false)
        }
    }

    // Codable stuff begins
    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case id = "id"
        case reports = "reports"
    }

    required public init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.reports.rawValue) as! [EventReportable]
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(reports, forKey: Coding.reports.rawValue)
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
}
