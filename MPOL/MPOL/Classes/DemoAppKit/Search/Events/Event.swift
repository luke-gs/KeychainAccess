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

    // MARK: - Properties

    /// The creation date of event
    public let creationDate: Date

    /// The title to display for the event
    public var title: String?

    /// The status of the event
    public var status: EventStatus = .draft

    /// Store of all entities used in event
    public var entityBucket: EntityBucket = EntityBucket(limit: 0)

    /// The nested reports
    private(set) public var reports: [EventReportable] = [] {
        didSet {
            updateChildReports()
            evaluator.updateEvaluation(for: .allValid)
        }
    }

    /// The storage for relationships between entities in the event
    public let relationshipManager = RelationshipManager<MPOLKitEntity, MPOLKitEntity>()

    // MARK: - State

    public var evaluator: Evaluator = Evaluator()

    // MARK: - Init

    public init() {
        creationDate = Date()
        super.init(id: UUID().uuidString)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.allValid) { [weak self] in
            guard let `self` = self else { return false }
            return self.reportsValid
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

    private var reportsValid: Bool {
        return reports.reduce(true, { result, report in
            return result && report.evaluator.isComplete
        })
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        // Update our evaluator if any evaluator we are observing changes
        self.evaluator.updateEvaluation(for: .allValid)
    }

    required init(unboxer: Unboxer) throws {
        MPLUnimplemented()
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case entities
        case relationships
        case reports
        case status
        case title
        case creationDate
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try container.decode(EventStatus.self, forKey: .status)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        relationshipManager.add(try container.decode([Relationship].self, forKey: .relationships))

        // Restore reports
        let anyReports = try container.decode([AnyEventReportable].self, forKey: .reports)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        reports = anyReports.map { $0.report }

        // Restore entity bucket
        let wrappedEntities = try container.decode([CodableWrapper].self, forKey: .entities)
        let entityList: [MPOLKitEntity] = wrappedEntities.unwrapped()
        entityBucket.add(entityList)
        // TODO: check the entity manager will update our snapshots if newer objects already in manager

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        // Convert our array of protocols to concrete classes, for Codable
        let anyReports = reports.map { return AnyEventReportable($0) }

        // Convert entity map to wrapped array
        let entityList: [MPOLKitEntity] = entityBucket.entities
        let wrappedEntities = entityList.wrapped()

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(title, forKey: .title)
        try container.encode(relationshipManager.relationships, forKey: .relationships)
        try container.encode(wrappedEntities, forKey: CodingKeys.entities)
        try container.encode(anyReports, forKey: CodingKeys.reports)
        try container.encode(creationDate, forKey: CodingKeys.creationDate)
    }
}
