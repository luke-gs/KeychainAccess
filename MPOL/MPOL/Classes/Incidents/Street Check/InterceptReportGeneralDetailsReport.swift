//
//  InterceptReportGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import DemoAppKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

open class InterceptReportGeneralDetailsReport: Reportable {

    public let weakEvent: Weak<Event>
    public let weakIncident: Weak<Incident>

    public let evaluator: Evaluator = Evaluator()
    public var selectedSubject: String? {
        didSet {
            evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var selectedSecondarySubject: String? {
        didSet {
             evaluator.updateEvaluation(for: .hasRequiredData)
        }
    }
    public var remarks: String?

    public required init(event: Event, incident: Incident) {
        self.weakEvent = Weak(event)
        self.weakIncident = Weak(incident)
        commonInit()
    }

    private func commonInit() {
        if let event = event {
            evaluator.addObserver(event)
        }
        if let incident = incident {
            evaluator.addObserver(incident)
        }

        evaluator.registerKey(.hasRequiredData) {
            return self.selectedSubject != nil && self.selectedSecondarySubject != nil
        }
    }

    // Coding
    public static var supportsSecureCoding: Bool = true
    
    private enum Coding: String {
        case incidents
        case event
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
        aCoder.encodeWeakObject(weakObject: weakIncident, forKey: Coding.incidents.rawValue)
    }

    public required init?(coder aDecoder: NSCoder) {
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        weakIncident = aDecoder.decodeWeakObject(forKey: Coding.incidents.rawValue)
    	commonInit()
    }

    // Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {}

}

extension InterceptReportGeneralDetailsReport: Summarisable {
    
    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Subject", detail: selectedSubject ?? "Required").detailColorKey(selectedSubject == nil ? .redText : nil))
        items.append(RowDetailFormItem(title: "Seconday Subject", detail: selectedSecondarySubject ?? "Required").detailColorKey(selectedSecondarySubject == nil ? .redText : nil))
        if let remarks = remarks {
            items.append(RowDetailFormItem(title: "Remarks", detail: remarks))
        }
        return items
    }
}



