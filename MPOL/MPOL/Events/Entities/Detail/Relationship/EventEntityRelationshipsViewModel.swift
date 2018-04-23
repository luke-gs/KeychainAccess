//
//  EventEntityRelationshipsViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

class EventEntityRelationshipsViewModel {
    var report: EventEntityRelationshipsReport

    init(report: EventEntityRelationshipsReport) {
        self.report = report
    }

    func tintColour() -> UIColor {
        return report.evaluator.isComplete == true ? .midGreen : .red
    }
}
