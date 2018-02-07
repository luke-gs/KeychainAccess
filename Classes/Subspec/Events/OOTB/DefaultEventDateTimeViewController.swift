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
        sidebarItem.color = .red    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder += HeaderFormItem(text: "REPORTED ON")

        builder += DateFormItem()
            .title("Report Time")
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.reportedOnDateTime = date
            }
            .required()

        builder += HeaderFormItem(text: "TOOK PLACE FROM")

        builder += DateFormItem()
            .title("Start")
            .datePickerMode(.dateAndTime)
            .withNowButton(true)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.tookPlaceFromStartDateTime = date
            }
            .required()

        builder += DateFormItem()
            .title("End")
            .datePickerMode(.dateAndTime)
            .width(.column(2))
            .onValueChanged { date in
                self.report?.tookPlacefromEndDateTime = date
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .green : .red
    }
}


/// The OOTB Date Time Report
public class DefaultDateTimeReport: Reportable {

    var reportedOnDateTime: Date? {
        didSet {
            evaluator.updateEvaluation(for: .reportedOnDateTime)
        }
    }

    var tookPlaceFromStartDateTime: Date? {
        didSet {
            evaluator.updateEvaluation(for: .tookPlaceFromStartDateTime)
        }
    }

    var tookPlacefromEndDateTime: Date?

    public weak var event: Event?
    public var evaluator: Evaluator = Evaluator()

    public required init(event: Event) {
        self.event = event

        evaluator.addObserver(event)
        evaluator.registerKey(.reportedOnDateTime) {
            return self.reportedOnDateTime != nil
        }
        evaluator.registerKey(.tookPlaceFromStartDateTime) {
            return self.tookPlaceFromStartDateTime != nil
        }
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: Keys.self)
        reportedOnDateTime = try container.decode(Date.self, forKey: .reportedOnDateTime)
        tookPlaceFromStartDateTime = try container.decode(Date.self, forKey: .tookPlaceFromStartDateTime)
        tookPlacefromEndDateTime = try container.decode(Date.self, forKey: .tookPlacefromEndDateTime)
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: Keys.self)
        try container.encode(reportedOnDateTime, forKey: .reportedOnDateTime)
        try container.encode(tookPlaceFromStartDateTime, forKey: .tookPlaceFromStartDateTime)
        try container.encode(tookPlacefromEndDateTime, forKey: .tookPlacefromEndDateTime)
    }

    enum Keys: String, CodingKey {
        case reportedOnDateTime = "reportedOnDateTime"
        case tookPlaceFromStartDateTime = "tookPlaceFromStartDateTime"
        case tookPlacefromEndDateTime = "tookPlacefromEndDateTime"
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }
}


