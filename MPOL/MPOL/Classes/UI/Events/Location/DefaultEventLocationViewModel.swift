//
//  DefaultEventLocationViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit

public class DefaultEventLocationViewModel {

    weak var report: DefaultLocationReport!

    /// As we prefill the event with an empty location this count returns 1 when locations array is empty
    var displayCount: Int {
        return report.eventLocations.isEmpty ? 1 : report.eventLocations.count
    }

    init(report: DefaultLocationReport) {
        self.report = report
    }

    // TODO: invovlement will currently always be "no involvements" as the location flow doesnt currently return the selected involvements
    func invovlements(for location: EventLocation) -> StringSizable? {

        let noInvolvementText = NSAttributedString(string: "No Involvements", attributes: [.foregroundColor: UIColor.orangeRed])
        return LocationSelectionCore(eventLocation: location)?.type?.title ?? noInvolvementText
    }

    var tabColors: (defaultColor: UIColor, selectedColor: UIColor) {
        if report.evaluator.isComplete {
            return (defaultColor: .midGreen, selectedColor: .midGreen)
        } else {
            return (defaultColor: .secondaryGray, selectedColor: .tabBarWhite)
        }
    }
}
