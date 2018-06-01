//
//  DomesticViolencePropertyReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

fileprivate extension EvaluatorKey {
    static let viewed = EvaluatorKey("viewed")
}

class DomesticViolencePropertyReport: Reportable {
    let weakEvent: Weak<Event>
    let weakIncident: Weak<Incident>

    private(set)var propertyList: [Property] = []

    let evaluator: Evaluator = Evaluator()

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

    public func addProperty(property: Property) {
        self.propertyList.append(property)
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

extension DomesticViolencePropertyReport: Summarisable {
    // TODO: Implement Summary Form Items once other functionality is complete
    var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Property", detail: "Not Yet Implemented"))
        return items
    }
}
