//
//  InterceptReportGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

open class InterceptReportGeneralDetailsReport: DefaultReportable {

    public var selectedSubject: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var selectedSecondarySubject: String? {
        didSet {
             evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var remarks: String?

    public override init(event: Event, incident: Incident) {
        super.init(event: event, incident: incident)
        commonInit()
    }

    private func commonInit() {
        evaluator.registerKey(.hasRequiredData) { [weak self] in
            guard let `self` = self else { return false }
            return self.selectedSubject != nil && self.selectedSecondarySubject != nil
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case selectedSubject
        case selectedSecondarySubject
        case remarks
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedSubject = try container.decodeIfPresent(String.self, forKey: .selectedSubject)
        selectedSecondarySubject = try container.decodeIfPresent(String.self, forKey: .selectedSecondarySubject)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedSubject, forKey: CodingKeys.selectedSubject)
        try container.encode(selectedSecondarySubject, forKey: CodingKeys.selectedSecondarySubject)
        try container.encode(remarks, forKey: CodingKeys.remarks)
    }

}

extension InterceptReportGeneralDetailsReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Subject", detail: selectedSubject ?? "Required")
            .styleIdentifier(selectedSubject == nil ? DemoAppKitStyler.summaryRequiredStyle : nil))
        items.append(RowDetailFormItem(title: "Seconday Subject", detail: selectedSecondarySubject ?? "Required").styleIdentifier(selectedSecondarySubject == nil ? DemoAppKitStyler.summaryRequiredStyle : nil))
        if let remarks = remarks {
            items.append(RowDetailFormItem(title: "Remarks", detail: remarks))
        }
        return items
    }
}
