//
//  InterceptReportGeneralDetailsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class InterceptReportGeneralDetailsViewModel {

    public let report: InterceptReportGeneralDetailsReport

    public required init(report: InterceptReportGeneralDetailsReport) {
        self.report = report
    }

    public var headerFormItemTitle: String {
        return "General"
    }

    public var subjectOptions: [String] {
        return ["Subject 1", "Subject 2", "Subject 3"]
    }

    public var secondarySubjectOptions: [String] {
        return ["Secondary Subject 1", "Secondary Subject 2", "Secondary Subject 3"]
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }
}
