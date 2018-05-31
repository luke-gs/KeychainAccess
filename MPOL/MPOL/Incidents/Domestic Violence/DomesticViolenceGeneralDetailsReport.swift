//
//  DomesticViolenceGeneralDetailsReport.swift
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

class DomesticViolenceGeneralDetailsReport: Reportable {
    weak var event: Event?
    weak var incident: Incident?
    let evaluator: Evaluator = Evaluator()

    var childCount: Int = 0
    var childrenToBeNamed: Bool = false
    var associateToBeNamed: Bool = false
    var details: String? = nil
    var remarks: String? = nil

    public var viewed: Bool = false{
        didSet {
            evaluator.updateEvaluation(for: .viewed)
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

        evaluator.registerKey(.viewed) {
            return self.viewed
        }
    }

    func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }

    // MARK: CODING
    public static var supportsSecureCoding: Bool = true
    public required init?(coder aDecoder: NSCoder) {}
    public func encode(with aCoder: NSCoder) {}
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
