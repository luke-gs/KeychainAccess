//
//  OfficerListReport.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class OfficerListReport: Reportable {

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

    public weak var event: Event?
    public weak var incident: Incident?

    public required init(event: Event) {
        self.event = event

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
                && self.officers.count > 0
        }
    }

    // Codable

    public static var supportsSecureCoding: Bool = true
    private enum Coding: String {
        case event
    }


    public required init?(coder aDecoder: NSCoder) {
        event = aDecoder.decodeObject(of: Event.self, forKey: Coding.event.rawValue)
        commonInit()
    }


    public func encode(with aCoder: NSCoder) {
        aCoder.encode(event, forKey: Coding.event.rawValue)
    }

    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}
