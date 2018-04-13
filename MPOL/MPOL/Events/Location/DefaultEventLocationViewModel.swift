//
//  DefaultEventLocationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

public class DefaultEventLocationViewModel {

    weak var report: DefaultLocationReport!

    init(report: DefaultLocationReport) {
        self.report = report
    }

    public func tabColour() -> UIColor {
        return report.evaluator.isComplete == true ? .midGreen : .red
    }
}
