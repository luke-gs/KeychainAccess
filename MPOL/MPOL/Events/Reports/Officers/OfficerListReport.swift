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

    public weak var event: Event?

    public enum CodingKeys: String, CodingKey {
        case officers
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

    public func titleHeader() -> String? {
        let officerCount = officers.count
        return "\(officerCount) CURRENT OFFICER\(officerCount == 1 ? "" : "S")"
    }

    public required init(event: Event) {
        self.event = event

        let user = UserSession.current.user
        let testOfficer = Officer()
        testOfficer.givenName = user?.username
        testOfficer.involvements = ["Reporting Officer"]

        officers = [testOfficer]

        evaluator.addObserver(event)

        evaluator.registerKey(.officers) {
            return self.viewed == true
                && self.officers.count > 0
        }
    }

    // Codable

    public required init(from: Decoder) throws {
        let container = try from.container(keyedBy: CodingKeys.self)
        officers = try container.decode(Array<Officer>.self, forKey: .officers)
    }

    public func encode(to: Encoder) throws {
        var container = to.container(keyedBy: CodingKeys.self)
        try container.encode(officers, forKey: .officers)
    }


    // Evaluation

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {

    }
}
