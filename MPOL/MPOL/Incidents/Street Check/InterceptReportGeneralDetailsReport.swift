//
//  InterceptReportGeneralDetailsReport.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

fileprivate extension EvaluatorKey {
    static let hasRequiredData = EvaluatorKey("hasRequiredData")
}

open class InterceptReportGeneralDetailsReport: Reportable {

    public weak var event: Event?
    public weak var incident: Incident?
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

    public required init(event: Event, incident: Incident? = nil) {
        self.event = event
        self.incident = incident
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
    }

    public func encode(with aCoder: NSCoder) { }
    public required init?(coder aDecoder: NSCoder) {
    	commonInit()
    }

    // Evaluation
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) { }

}

extension InterceptReportGeneralDetailsReport: Summarisable {
    
    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(RowDetailFormItem(title: "Subject", detail: selectedSubject ?? "Not Set").detailColorKey(selectedSubject == nil ? .redText : nil))
        items.append(RowDetailFormItem(title: "Seconday Subject", detail: selectedSecondarySubject ?? "Not Set").detailColorKey(selectedSecondarySubject == nil ? .redText : nil))
        if let remarks = remarks {
            items.append(RowDetailFormItem(title: "Remarks", detail: remarks))
        }
        return items
    }
}



