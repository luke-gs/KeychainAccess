//
//  DomesticViolenceGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

class DomesticViolenceGeneralDetailsReport: DefaultReportable {

    var childCount: Int = 0
    var childrenToBeNamed: Bool = false
    var associateToBeNamed: Bool = false
    var details: String?
    var remarks: String?

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case childCount
        case childrenToBeNamed
        case associateToBeNamed
        case details
        case remarks
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        childCount = try container.decode(Int.self, forKey: .childCount)
        childrenToBeNamed = try container.decode(Bool.self, forKey: .childrenToBeNamed)
        associateToBeNamed = try container.decode(Bool.self, forKey: .associateToBeNamed)
        details = try container.decodeIfPresent(String.self, forKey: .details)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(childCount, forKey: CodingKeys.childCount)
        try container.encode(childrenToBeNamed, forKey: CodingKeys.childrenToBeNamed)
        try container.encode(associateToBeNamed, forKey: CodingKeys.associateToBeNamed)
        try container.encode(details, forKey: CodingKeys.details)
        try container.encode(remarks, forKey: CodingKeys.remarks)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

}

extension DomesticViolenceGeneralDetailsReport: Summarisable {
    var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Number of Children", detail: "\(childCount)"))
        items.append(RowDetailFormItem(title: "Children to be Named", detail: childrenToBeNamed ? "Yes" : "No"))
        items.append(RowDetailFormItem(title: "Relative/Associate to be Named", detail: associateToBeNamed ? "Yes" : "No"))
        if let details = details {
            items.append(RowDetailFormItem(title: "Details", detail: details))
        }
        if let remarks = remarks {
            items.append(RowDetailFormItem(title: "Remarks", detail: remarks))
        }
        return items
    }
}
