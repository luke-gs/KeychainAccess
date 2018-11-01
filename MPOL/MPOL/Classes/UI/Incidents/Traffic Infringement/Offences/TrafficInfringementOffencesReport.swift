//
//  TrafficInfringementOffencesReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let hasOffence = EvaluatorKey("hasOffence")
}

class TrafficInfringementOffencesReport: DefaultReportable {

    var offences: [Offence] = [] {
        didSet {
            evaluator.updateEvaluation(for: .hasOffence)
        }
    }

    public override init(event: Event, incident: Incident) {
        super.init(event: event, incident: incident)
    }

    override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.hasOffence) { [weak self] in
            guard let `self` = self else { return false }
            return !self.offences.isEmpty
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case offences
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offences = try container.decode([Offence].self, forKey: .offences)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offences, forKey: CodingKeys.offences)
    }

}

extension TrafficInfringementOffencesReport: Summarisable {
    var formItems: [FormItem] {
        var items = [FormItem]()
        let titleText = String.localizedStringWithFormat(NSLocalizedString("%d offences", comment: ""), offences.count)
        let demerits = offences.map { $0.demeritValue}.reduce(0, +)
        let fine = offences.map {$0.fineValue}.reduce(0, +)
        let descriptionText = "\(demerits) Total Demerit" + (demerits == 0 || demerits > 1 ? "s" : "") + ", $" + String(format: "%.2f", fine)
        items.append(RowDetailFormItem(title: titleText, detail: descriptionText))
        return items
    }
}
