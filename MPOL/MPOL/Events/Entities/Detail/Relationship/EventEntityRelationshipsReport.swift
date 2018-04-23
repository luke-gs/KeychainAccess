//
//  EventEntityRelationshipsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

class EventEntityRelationshipsReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
    weak var entity: MPOLKitEntity?

    init(event: Event, entity: MPOLKitEntity) {
        self.event = event
        self.entity = entity
    }

    //MARK: Eval
    var evaluator: Evaluator = Evaluator()
    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

    //MARK: Coding
    static var supportsSecureCoding: Bool = true
    required init?(coder aDecoder: NSCoder) { MPLCodingNotSupported() }
    func encode(with aCoder: NSCoder) { }
}
