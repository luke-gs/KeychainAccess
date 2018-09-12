//
//  DomesticViolenceGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

class DomesticViolenceGeneralDetailsReport: Reportable {
    let weakIncident: Weak<Incident>
    let weakEvent: Weak<Event>

    let evaluator: Evaluator = Evaluator()

    var childCount: Int = 0
    var childrenToBeNamed: Bool = false
    var associateToBeNamed: Bool = false
    var details: String? = nil
    var remarks: String? = nil

    public var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .viewed)
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

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

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

extension DomesticViolenceGeneralDetailsReport: Summarisable {
    var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Number of Children", detail: "\(childCount)"))
        items.append(RowDetailFormItem(title: "Children to be Named", detail: childrenToBeNamed ? "Yes" : "No"))
        items.append(RowDetailFormItem(title: "Relative/Associate to be Named", detail: associateToBeNamed ? "Yes" : "No"))
        if let details = details {
            items.append(RowDetailFormItem(title: "Details", detail: details))
        }
        if let remarks = remarks {
            items.append(RowDetailFormItem(title: "Remarks", detail: remarks))
        }
        return items
    }
}
