//
//  DefaultEventNotesMediaViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public class DefaultEventNotesMediaViewModel {

    weak var report: DefaultNotesMediaReport!

    public init(report: DefaultNotesMediaReport) {
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
