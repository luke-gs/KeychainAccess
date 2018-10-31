//
//  Reportable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// A convenience for objects that will want to conform to both
/// an eventReportable as well as incidentReportable
public protocol Reportable: IncidentReportable, EventReportable { }

/// Conforming to this protocol ensures that you have a weak reference
/// to the event object
public protocol EventReportable: Codable, Evaluatable {

    /// A reference to the event object
    var weakEvent: Weak<Event> { get set }
}

extension EventReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the event
    public var event: Event? {
        return weakEvent.object
    }
}

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

public protocol ActionReportable: IncidentReportable {

    /// A weak reference to the additional action object
    /// Make sure this is weak in implementation as well
    var weakAdditionalAction: Weak<AdditionalAction> { get set }
}

extension ActionReportable {

    /// Convenience property to acccess the underlying
    /// weak object of the incident
    public var additionalAction: AdditionalAction? {
        return weakAdditionalAction.object
    }
}

/// A type-erased version of EventReportable that can be used in Codable serialization
open class AnyEventReportable: EventReportable {

    public let report: EventReportable

    public init(_ report: EventReportable) {
        self.report = report
    }

    // MARK: - EventReportable

    public var weakEvent: Weak<Event> {
        get {
            return report.weakEvent
        }
        set {
            report.weakEvent = newValue
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
        report = reportWrapper.object as! EventReportable
    }

    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodableWrapper(report), forKey: CodingKeys.report)
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
