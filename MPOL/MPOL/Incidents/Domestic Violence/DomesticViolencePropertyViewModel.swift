//
//  DomesticViolencePropertyViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class DomesticViolencePropertyViewModel {

    let report: DomesticViolencePropertyReport

    init(report: DomesticViolencePropertyReport) {
        self.report = report
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public var hasProperty: Bool {
        return !report.propertyList.isEmpty
    }

    func addObserver(_ observer: EvaluationObserverable) {
        report.evaluator.addObserver(observer)
    }
}
