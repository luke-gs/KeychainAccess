//
//  DomesticViolencePropertyReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

class DomesticViolencePropertyReport: DefaultReportable {

    var propertyList: [PropertyDetailsReport] = []

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
        }
    }

    public override init(event: Event, incident: Incident) {
        super.init(event: event, incident: incident)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case propertyList
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        propertyList = try container.decode([PropertyDetailsReport].self, forKey: .propertyList)
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(propertyList, forKey: CodingKeys.propertyList)
        try container.encode(viewed, forKey: CodingKeys.viewed)
    }

}

extension DomesticViolencePropertyReport: Summarisable {
    public var formItems: [FormItem] {
        return [RowDetailFormItem(title: "Property", detail: "\(propertyList.count)")]
            + propertyList.compactMap { property in
                return DetailFormItem(title: property.property?.subType,
                                      subtitle: property.property?.type,
                                      detail: nil,
                                      image: nil)
        }
    }
}
