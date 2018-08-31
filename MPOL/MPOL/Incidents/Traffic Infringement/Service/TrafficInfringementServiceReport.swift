//
//  TrafficInfringementServiceReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

fileprivate extension EvaluatorKey {
    static let hasContactDetails = EvaluatorKey("hasContactDetails")
}

class TrafficInfringementServiceReport: Reportable {
    let weakEvent: Weak<Event>
    let weakIncident: Weak<Incident>

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
        self.weakEvent = Weak(event)
        self.weakIncident = Weak(incident)

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

    private enum Coding: String {
        case event
        case incident
    }

    public static var supportsSecureCoding: Bool = true

    public required init?(coder aDecoder: NSCoder) {
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        weakIncident = aDecoder.decodeWeakObject(forKey: Coding.incident.rawValue)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
        aCoder.encodeWeakObject(weakObject: weakIncident, forKey: Coding.incident.rawValue)
    }
}

extension TrafficInfringementServiceReport: Summarisable {
    var formItems: [FormItem] {
        var items = [FormItem]()
        if let email = selectedEmail {
            items.append(RowDetailFormItem(title: "Email", detail: email))
        }
        if let mobile = selectedMobile {
            items.append(RowDetailFormItem(title: "Mobile", detail: mobile))
        }
        if let address = selectedAddress {
            items.append(RowDetailFormItem(title: "Address", detail: address))
        } else if items.isEmpty {
            items.append(RowDetailFormItem(title: "No Service Details Set", detail: nil))
        }
        return items
    }
}
