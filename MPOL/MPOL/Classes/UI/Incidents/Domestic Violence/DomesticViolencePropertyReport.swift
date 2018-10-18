//
//  DomesticViolencePropertyReport.swift
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

class DomesticViolencePropertyReport: Reportable {
    let weakEvent: Weak<Event>
    let weakIncident: Weak<Incident>

    var propertyList: [PropertyDetailsReport] = []

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

        evaluator.registerKey(.viewed) { [weak self] in
            return self?.viewed ?? false
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

extension DomesticViolencePropertyReport: Summarisable {
    public var formItems: [FormItem] {
        return [RowDetailFormItem(title: "Property", detail: "\(propertyList.count)")]
            + propertyList.compactMap { property in
                return DetailFormItem(title: property.property?.subType,
                                      subtitle: property.property?.type,
                                      detail: nil,
                                      image: nil)
        }
    }
}

