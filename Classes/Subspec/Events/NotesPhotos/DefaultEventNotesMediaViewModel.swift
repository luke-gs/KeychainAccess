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

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public func operationNameChanged(_ name: String?) {
        report.operationName = name
    }

    public func freeTextChanged(_ text: String?) {
        report.freeText = text
    }
}
