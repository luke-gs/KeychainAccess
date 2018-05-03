//
//  TrafficInfringementServiceReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate extension EvaluatorKey {
    static let hasContactDetails = EvaluatorKey("hasContactDetails")
}

class TrafficInfringementServiceReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
    let evaluator: Evaluator = Evaluator()
    open var selectedServiceType: ServiceType?
    open var selectedEmail: String?
    open var selectedMobile: String?
    open var selectedAddress: String?

    var hasContactDetails: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .hasContactDetails)
        }
    }

    init(event: Event, incident: Incident) {
        self.event = event
        self.incident = incident

        if let event = self.event {
            evaluator.addObserver(event)
        }
        if let incident = self.incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.hasContactDetails) {
            return self.hasContactDetails
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
}


