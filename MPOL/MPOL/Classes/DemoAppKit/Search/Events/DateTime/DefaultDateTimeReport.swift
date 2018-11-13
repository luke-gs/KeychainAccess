//
//  DefaultDateTimeReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

internal extension EvaluatorKey {
    static let reportedOnDateTime = EvaluatorKey(rawValue: "reportedOnDateTime")
    static let tookPlaceFromStartDateTime = EvaluatorKey(rawValue: "tookPlaceFromStartDateTime")
}

open class DefaultDateTimeReport: DefaultEventReportable {

    public var reportedOnDateTime: Date? {
        didSet {
            evaluator.updateEvaluation(for: .reportedOnDateTime)
        }
    }

    public var tookPlaceFromStartDateTime: Date? {
        didSet {
            evaluator.updateEvaluation(for: .tookPlaceFromStartDateTime)
        }
    }

    public var tookPlaceFromEndDateTime: Date?

    public override init(event: Event) {
        super.init(event: event)
    }

    open override func configure(with event: Event) {
        super.configure(with: event)

        evaluator.registerKey(.reportedOnDateTime) { [weak self] in
            guard let `self` = self else { return false }
            return self.reportedOnDateTime != nil
        }
        evaluator.registerKey(.tookPlaceFromStartDateTime) { [weak self] in
            guard let `self` = self else { return false }
            return self.tookPlaceFromStartDateTime != nil
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case reportedOnDateTime
        case tookPlaceFromStartDateTime
        case tookPlaceFromEndDateTime
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reportedOnDateTime = try container.decodeIfPresent(Date.self, forKey: .reportedOnDateTime)
        tookPlaceFromStartDateTime = try container.decodeIfPresent(Date.self, forKey: .tookPlaceFromStartDateTime)
        tookPlaceFromEndDateTime = try container.decodeIfPresent(Date.self, forKey: .tookPlaceFromEndDateTime)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reportedOnDateTime, forKey: CodingKeys.reportedOnDateTime)
        try container.encode(tookPlaceFromStartDateTime, forKey: CodingKeys.tookPlaceFromStartDateTime)
        try container.encode(tookPlaceFromEndDateTime, forKey: CodingKeys.tookPlaceFromEndDateTime)

        try super.encode(to: encoder)
    }

}

extension DefaultDateTimeReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()

        items.append(LargeTextHeaderFormItem(text: "Date and Time"))

        let dateReported = self.reportedOnDateTime?.asPreferredDateTimeString()
        let dateStart = self.tookPlaceFromStartDateTime?.asPreferredDateTimeString()

        items.append(RowDetailFormItem(title: "Reported On", detail: dateReported ?? "Required")
            .styleIdentifier(dateReported == nil ? DemoAppKitStyler.summaryRequiredStyle : nil))
        items.append(RowDetailFormItem(title: "Start Date", detail: dateStart ?? "Required")
            .styleIdentifier(dateStart == nil ? DemoAppKitStyler.summaryRequiredStyle : nil))

        if let dateEnd = self.tookPlaceFromEndDateTime?.asPreferredDateTimeString() {
            items.append(RowDetailFormItem(title: "End Date", detail: dateEnd))
        }

        return items
    }
}
