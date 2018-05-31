//
//  DefaultDateTimeReport.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class DefaultDateTimeReport: Reportable {

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

    public var evaluator: Evaluator = Evaluator()
    public weak var event: Event?
    public weak var incident: Incident?

    public required init(event: Event) {
        self.event = event
        commonInit()
    }

    private func commonInit() {
        if let event = event { evaluator.addObserver(event) }
        evaluator.registerKey(.reportedOnDateTime) {
            return self.reportedOnDateTime != nil
        }
        evaluator.registerKey(.tookPlaceFromStartDateTime) {
            return self.tookPlaceFromStartDateTime != nil
        }
    }

    // Codable

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case reportedOnDateTime
        case tookPlaceFromStartDateTime
        case tookPlaceFromEndDateTime
    }

    public required init?(coder aDecoder: NSCoder) {
        reportedOnDateTime = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.reportedOnDateTime.rawValue) as Date?
        tookPlaceFromStartDateTime = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.tookPlaceFromStartDateTime.rawValue) as Date?
        tookPlaceFromEndDateTime = aDecoder.decodeObject(of: NSDate.self, forKey: Coding.tookPlaceFromEndDateTime.rawValue) as Date?
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(reportedOnDateTime, forKey: Coding.reportedOnDateTime.rawValue)
        aCoder.encode(tookPlaceFromStartDateTime, forKey: Coding.tookPlaceFromStartDateTime.rawValue)
        aCoder.encode(tookPlaceFromEndDateTime, forKey: Coding.tookPlaceFromEndDateTime.rawValue)
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

}

extension DefaultDateTimeReport: Summarisable {

    public var formItems: [FormItem] {
        var items = [FormItem]()

        items.append(LargeTextHeaderFormItem(text: "Date and Time"))

        let dateReported = self.reportedOnDateTime?.asPreferredDateTimeString()
        let dateStart = self.tookPlaceFromStartDateTime?.asPreferredDateTimeString()

        items.append(RowDetailFormItem(title: "Reported On", detail: dateReported ?? "Not Set").detailColorKey(dateReported == nil ? .redText : nil))
        items.append(RowDetailFormItem(title: "Start Date", detail: dateStart ?? "Not Set").detailColorKey(dateStart == nil ? .redText : nil))

        if let dateEnd = self.tookPlaceFromEndDateTime?.asPreferredDateTimeString() {
            items.append(RowDetailFormItem(title: "End Date", detail: dateEnd))
        }

        return items
    }
}

