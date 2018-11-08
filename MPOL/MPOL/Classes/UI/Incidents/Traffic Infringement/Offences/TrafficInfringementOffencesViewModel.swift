//
//  TrafficInfringementOffencesViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class TrafficInfringementOffencesViewModel {

    public var title: String
    private(set) var report: TrafficInfringementOffencesReport

    public required init(report: Reportable) {
        self.report = report as! TrafficInfringementOffencesReport
        self.title = "Offences"
    }

    public var headerFormItemTitle: String {
        return String.localizedStringWithFormat(NSLocalizedString("%d offences", comment: ""), report.offences.count)
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    public func addOffence(offence: Offence) {
        report.offences.append(offence)
    }

    public func hasOffences() -> Bool {
        return report.offences.count > 0
    }

    public func removeOffence(at index: Int) {
        report.offences.remove(at: index)
    }

    public var totalDemerits: Int {
        return report.offences.map { $0.demeritValue }.reduce(0, +)
    }

    public var totalDemeritsString: String {
        return String(totalDemerits)
    }

    public var totalFine: Float {
        return report.offences.map { $0.fineValue }.reduce(0.0, +)
    }

    public var totalFineString: String {
        return "$" + String(format: "%.2f", totalFine)
    }
}
