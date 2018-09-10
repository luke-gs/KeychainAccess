//
//  OfficerListReport.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit

public class OfficerListReport: EventReportable {
    public let weakEvent: Weak<Event>

    public enum CodingKeys: String, CodingKey {
        case officers
        case event
    }

    public let evaluator: Evaluator = Evaluator()

    var viewed: Bool = false {
        didSet {
            evaluator.updateEvaluation(for: .officers)
        }
    }

    var officers: [Officer] = [] {
        didSet {
            evaluator.updateEvaluation(for: .officers)
        }
    }

    public required init(event: Event) {
        self.weakEvent = Weak(event)

        let testOfficer = UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey) as! Officer
        testOfficer.involvements = ["Reporting Officer"]

        officers = [testOfficer]

        commonInit()
    }

    private func commonInit() {
        if let event = event {
            evaluator.addObserver(event)
        }

        evaluator.registerKey(.officers) {
            return self.viewed == true
                && self.officers.reduce(true, { (result, officer) -> Bool in
                    return result && !officer.involvements.isEmpty
                })
                && self.officers.flatMap{$0.involvements}.contains(where: {$0.caseInsensitiveCompare("reporting officer") == .orderedSame})
        }
    }

    // Codable

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case event
    }


    public required init?(coder aDecoder: NSCoder) {
        weakEvent = aDecoder.decodeWeakObject(forKey: Coding.event.rawValue)
        commonInit()
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encodeWeakObject(weakObject: weakEvent, forKey: Coding.event.rawValue)
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}

extension OfficerListReport: Summarisable {
    
    public var formItems: [FormItem] {
        var items = [FormItem]()
        items.append(LargeTextHeaderFormItem(text: "Officers"))
        officers.forEach { (officer) in
            if let givenName = officer.givenName, let familyName = officer.familyName {
                items.append(RowDetailFormItem(title: givenName + " " + familyName, detail: officer.involvements.map {$0}.joined(separator: ", ")))
            }
        }
        return items
    }
}
