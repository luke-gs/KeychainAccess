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

    public weak var incident: Incident?

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

    public init(incident: Incident, type: AdditionalActionType) {
        self.incident = incident
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
    }


    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: Coding.id.rawValue)! as String
        additionalActionType = AdditionalActionType(rawValue: aDecoder.decodeObject(of: NSString.self, forKey: Coding.additionalActionType.rawValue)! as String)
        reports = aDecoder.decodeObject(of: NSArray.self, forKey: Coding.reports.rawValue) as! [Reportable]
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: Coding.id.rawValue)
        aCoder.encode(additionalActionType.rawValue, forKey: Coding.additionalActionType.rawValue)
        aCoder.encode(reports, forKey: Coding.reports.rawValue)
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
public struct AdditionalActionType: RawRepresentable, Hashable {

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public static func ==(lhs: AdditionalActionType, rhs: AdditionalActionType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

