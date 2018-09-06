//
//  RetrievedEventSummaryViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class RetrievedEventSummaryViewModel {

    private var event: RetrievedEvent

    var eventName: StringSizable {
        let type = event.type ?? "Unknown"

        return NSAttributedString(string: type,
                                  attributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)])
    }

    var recordedDateLabel: StringSizable {
        return "Recorded On".withPreferredFont
    }

    var recordedDateValue: StringSizable {

        if let date = event.occurredDate {
            let formatedDate = DateFormatter.preferredDateStyle.string(from: date)
            return formatedDate.withPreferredFont
        }
        return "Unknown".withPreferredFont
    }

    var eventNumberLabel: StringSizable {
        return "Event Number".withPreferredFont
    }

    var eventNumberValue: StringSizable {

        let number = event.name ?? "Unknown"
        return number.withPreferredFont
    }

    var eventDescription: String {
        return event.eventDescription ?? "Unknown"
    }

    init(event: RetrievedEvent) {
        self.event = event
    }
}

fileprivate extension String {

    var withPreferredFont: StringSizable {
        return NSAttributedString(string: self,
                                  attributes: [.font: UIFont.systemFont(ofSize: 17.0)])
            .sizing()
    }
}
