//
//  EventEntitiesListReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import Foundation

fileprivate extension EvaluatorKey {
    static let valid = EvaluatorKey("valid")
}

public class EventEntitiesListReport: DefaultEventReportable {

    public var entityDetailReports: [EventEntityDetailReport] = [EventEntityDetailReport]() {
        didSet {
            evaluator.updateEvaluation(for: .valid)
        }
    }

    public override init(event: Event) {
        super.init(event: event)
    }

    public override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.valid) { [weak self] in
            guard let `self` = self else { return false }
            let reportsValid = self.entityDetailReports.reduce(true, { (result, report) -> Bool in
                return result && report.evaluator.isComplete
            })
            return !self.entityDetailReports.isEmpty && reportsValid
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case entityDetailReports
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entityDetailReports = try container.decode([EventEntityDetailReport].self, forKey: .entityDetailReports)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entityDetailReports, forKey: CodingKeys.entityDetailReports)
    }

}
