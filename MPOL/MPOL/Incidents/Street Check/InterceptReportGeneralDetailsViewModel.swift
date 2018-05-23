//
//  InterceptReportGeneralDetailsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class InterceptReportGeneralDetailsViewModel {

    public let report: InterceptReportGeneralDetailsReport

    var loadingManagerState: LoadingStateManager.State {
        return .noContent
    }

    public required init(report: InterceptReportGeneralDetailsReport) {
        self.report = report
    }

    public var headerFormItemTitle: String {
        return "General"
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }
}
