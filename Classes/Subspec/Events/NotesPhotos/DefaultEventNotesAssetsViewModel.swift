//
//  DefaultEventDateTimeViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class DefaultEventNotesAssetsViewModel {

    weak var report: DefaultNotesAssetsReport!

    public init(report: DefaultNotesAssetsReport) {
        self.report = report
    }

    public func tabColour() -> UIColor {
        return report.evaluator.isComplete ? .midGreen : .red
    }

    public func operationNameChanged(_ name: String?) {
        report.operationName = name
    }

    public func freeTextChanged(_ text: String?) {
        report.freeText = text
    }
}
