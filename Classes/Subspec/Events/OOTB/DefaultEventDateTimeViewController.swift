//
//  EventDateTimeViewController.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 15/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate extension EvaluatorKey {
    static let reportedOnDateTime = EvaluatorKey(rawValue: "reportedOnDateTime")
    static let tookPlaceFromStartDateTime = EvaluatorKey(rawValue: "tookPlaceFromStartDateTime")
}

/// The OOTB DateTime viewController
open class DefaultEventDateTimeViewController: FormBuilderViewController, EvaluationObserverable {

    weak var report: DefaultDateTimeReport?

    public init(report: Reportable?) {
        self.report = report as? DefaultDateTimeReport
        super.init()
        report?.evaluator.addObserver(self)
        
        sidebarItem.regularTitle = "Date and Time"
        sidebarItem.compactTitle = "Date and Time"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.date)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "REPORTED ON")

        builder += DateFormItem()
            .title("Report Time")
            .selectedValue(report?.reportedOnDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .maximumDate(Date())
            .selectedValue(self.report?.reportedOnDateTime)
            .onValueChanged { date in
                self.report?.reportedOnDateTime = date
            }
            .required()

        builder += HeaderFormItem(text: "TOOK PLACE FROM")

        builder += DateFormItem()
            .title("Start")
            .selectedValue(report?.tookPlaceFromStartDateTime)
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .selectedValue(self.report?.tookPlaceFromStartDateTime)
            .onValueChanged { date in
                guard let formItem = self.builder.formItem(for: "tookPlaceFromEndDateTime") as? DateFormItem else { return }
                self.adjustEndTime(for: date, in: formItem)
                self.report?.tookPlaceFromStartDateTime = date
            }
            .required()

        builder +=  DateFormItem()
            .title("End")
            .selectedValue(report?.tookPlaceFromEndDateTime)
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .elementIdentifier("tookPlaceFromEndDateTime")
            .minimumDate(Date())
            .onValueChanged { date in
                self.report?.tookPlaceFromEndDateTime = date
        }
        
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }

    //MARK: PRIVATE

    private func adjustEndTime(for date: Date?, in formItem: DateFormItem) {
        formItem.minimumDate = date
        guard date != report?.tookPlaceFromStartDateTime else { return }
        guard let startDate = date, let endDate = report?.tookPlaceFromEndDateTime else { return }
        if startDate > endDate {
            report?.tookPlaceFromEndDateTime = nil
            formItem.selectedValue = nil
            formItem.reloadItem()
        }
    }
}


/// The OOTB Date Time Report
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
