//
//  OfficerListReport.swift
//  MPOL
//
//  Created by QHMW64 on 8/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class OfficerListReport: DefaultEventReportable {

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

    public override init(event: Event) {
        super.init(event: event)
        commonInit()
    }

    private func commonInit() {
        let reportingOfficerText = NSLocalizedString("Reporting Officer", comment: "")

        if let currentOfficer: Officer = UserSession.current.userStorage?.retrieve(key: UserSession.currentOfficerKey) {
            currentOfficer.involvements = [reportingOfficerText]
            officers = [currentOfficer]
        }

        evaluator.registerKey(.officers) { [weak self] in
            guard let `self` = self else { return false }
            return self.viewed == true
                && self.officers.reduce(true, { (result, officer) -> Bool in
                    return result && !officer.involvements.isEmpty
                })
                && self.officers.flatMap {$0.involvements}.contains(where: {$0.compare(reportingOfficerText) == .orderedSame})
        }
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case officers
        case viewed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        officers = try container.decode([Officer].self, forKey: .officers)
        viewed = try container.decode(Bool.self, forKey: .viewed)

        try super.init(from: decoder)
        commonInit()
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(officers, forKey: CodingKeys.officers)
        try container.encode(viewed, forKey: CodingKeys.viewed)
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
