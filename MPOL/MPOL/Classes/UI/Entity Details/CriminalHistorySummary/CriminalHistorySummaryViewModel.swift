//
//  CriminalHistorySummaryViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class CriminalHistorySummaryViewModel {

    private var criminalHistory: CriminalHistory

    public var navBarTitle: String {
        switch criminalHistory {
        case is OffenderCharge:
            return NSLocalizedString("Charge", comment: "")
        case is OffenderConviction:
            return NSLocalizedString("Conviction", comment: "")
        default:
            return NSLocalizedString("Criminal History", comment: "")
        }
    }

    public var primaryCharge: StringSizable {

        let charge = criminalHistory.primaryCharge ?? "Unknown"
        return NSAttributedString(string: charge,
                                  attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)])
    }

    public var offenceDescription: StringSizable? {

        return criminalHistory.offenceDescription
    }

    var occurredDateLabel: StringSizable {
        return "Date Occurred".withPreferredFont
    }

    public var occurredDateValue: StringSizable? {

        if let date = criminalHistory.occurredDate {
            let formattedDate = DateFormatter.preferredDateStyle.string(from: date)
            return formattedDate.withPreferredFont
        }
        return "Unknown".withPreferredFont
    }

    var courtNameLabel: StringSizable {
        return "Court Name".withPreferredFont
    }

    public var courtNameValue: StringSizable {

        let courtName = criminalHistory.courtName ?? "Unknown"
        return courtName.withPreferredFont
    }

    public var courtDateLabel: StringSizable {
        switch criminalHistory {
        case is OffenderCharge:
            return "Next Court Date".withPreferredFont
        case is OffenderConviction:
            return "Final Court Date".withPreferredFont
        default:
            return ""
        }
    }

    public var courtDateValue: StringSizable {
        var courtDate: Date?

        if let charge = criminalHistory as? OffenderCharge, let date = charge.nextCourtDate {
            courtDate = date
        } else if let conviction = criminalHistory as? OffenderConviction, let date =  conviction.finalCourtDate {
            courtDate = date
        }

        if let date = courtDate {
            let formattedDate = DateFormatter.preferredDateStyle.string(from: date)
            return formattedDate.withPreferredFont
        } else {
            return "Unknown".withPreferredFont
        }
    }

    init(criminalHistory: CriminalHistory) {
        self.criminalHistory = criminalHistory
    }

}

fileprivate extension String {

    var withPreferredFont: StringSizable {
        return NSAttributedString(string: self,
                                  attributes: [.font: UIFont.systemFont(ofSize: 17.0)])
            .sizing()
    }
}
