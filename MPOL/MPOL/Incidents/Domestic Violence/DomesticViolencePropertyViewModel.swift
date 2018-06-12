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

    public var hasProperty: Bool {
        return !report.propertyList.isEmpty
    }

    public var headerTitle: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d properties", comment: ""), report.propertyList.count)
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    init(report: DomesticViolencePropertyReport) {
        self.report = report
    }

    func addObserver(_ observer: EvaluationObserverable) {
        report.evaluator.addObserver(observer)
    }

    func add(_ propertyDetailsReport: PropertyDetailsReport) {
        if let indexOfExistingProperty = report.propertyList.index(where: {$0.property == propertyDetailsReport.property}) {
            report.propertyList[indexOfExistingProperty] = propertyDetailsReport
        } else {
            report.propertyList.append(propertyDetailsReport)
        }
    }
}
