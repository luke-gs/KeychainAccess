//
//  IncidentReportable.swift
//  DemoAppKit
//
//  Created by Trent Fitzgibbon on 2/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Conforming to this protocol ensures that you have a weak reference
/// to the incident object
public protocol IncidentReportable: Codable, Evaluatable {

    /// A weak reference to the incident object
    var weakIncident: Weak<Incident> { get set }
}

extension IncidentReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the incident
    public var incident: Incident? {
        return weakIncident.object
    }
}

/// A type-erased version of EventReportable that can be used in Codable serialization
open class AnyIncidentReportable: IncidentReportable {

    public let report: IncidentReportable

    public init(_ report: IncidentReportable) {
        self.report = report
    }

    // MARK: - IncidentReportable

    public var weakIncident: Weak<Incident> {
        get {
            return report.weakIncident
        }
        set {
            report.weakIncident = newValue
        }
    }

    // MARK: - Evaluatable

    public var evaluator: Evaluator {
        return report.evaluator
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        report.evaluationChanged(in: evaluator, for: key, evaluationState: evaluationState)
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case report
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reportWrapper = try container.decode(CodableWrapper.self, forKey: .report)
        report = reportWrapper.object as! IncidentReportable
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodableWrapper(report), forKey: CodingKeys.report)
    }

}
