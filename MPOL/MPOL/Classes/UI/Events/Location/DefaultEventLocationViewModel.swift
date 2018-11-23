//
//  DefaultEventLocationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class DefaultEventLocationViewModel {

    /// This variable matches the 'eventLocation' location involvement manefest item
    public static var eventLocationInvolvement = NSLocalizedString("Event Location", comment: "")
    weak var report: DefaultLocationReport!

    /// As we prefill the event with an empty location this count returns 1 when locations array is empty
    var displayCount: Int {
        return report.eventLocations.isEmpty ? 1 : report.eventLocations.count
    }

    init(report: DefaultLocationReport) {
        self.report = report
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }

    // TODO: invovlement will currently always be "no involvements" as the location flow doesnt currently return the selected involvements
    func invovlements(for location: EventLocation) -> StringSizable? {

        let noInvolvementText = NSAttributedString(string: NSLocalizedString("No involvements", comment: ""),
                                                   attributes: [.foregroundColor: UIColor.orangeRed])
        return location.involvement ?? noInvolvementText
    }

    func removeLocation(at indexPath: IndexPath) {

        // check if location is 'Event Location' if so move this involvement to first location in list
        if report.eventLocations[indexPath.row].involvement?.string == DefaultEventLocationViewModel.eventLocationInvolvement {
            report.eventLocations[0].involvement = DefaultEventLocationViewModel.eventLocationInvolvement
        }

        report.eventLocations.remove(at: indexPath.row)
    }
}
