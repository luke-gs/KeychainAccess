//
//  EventBuilder.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

public class EventBuilder: EventBuilding {

    public func createEvent(eventType: EventType, incidentType: IncidentType?) -> Event {
        let event = Event()

        // Add reports here
        event.add(report: DefaultDateTimeReport(event: event))
        event.add(report: DefaultLocationReport(event: event))
        event.add(report: OfficerListReport(event: event))
        event.add(report: IncidentListReport(event: event))
        event.add(report: EventEntitiesListReport(event: event))
        event.add(report: DefaultNotesMediaReport(event: event))

        // TODO: move incident builder/manager so that we can create default incident here,
        // rather than when we open the event for the first time

        // Set initial title from incident
        if let incidentType = incidentType {
            event.title = incidentType.rawValue
        }

        return event
    }

    public func displayable(for event: Event) -> EventListItemViewModelable {

        // Use location of event as subtitle
        var location: String?
        if let locationReport = event.reports.compactMap({ $0 as? DefaultLocationReport }).first {
            location = locationReport.eventLocation?.addressString ?? "Location Unknown"
        }

        let creationDate = EventBuilder.dateFormatter.string(from: event.creationDate)
        let subtitle = [creationDate, location].joined(separator: "\n")
        let detail = event.submissionResult

        // Use image specific to status and theme
        let isDark = ThemeManager.shared.currentInterfaceStyle == .dark
        var image: UIImage?
        switch event.submissionStatus {
        case .draft:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .black : .white, circleColor: isDark ? .white : .black, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        default:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .white : .black, circleColor: isDark ? .darkGray : .disabledGray, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        }

        let selectable = event.submissionStatus == .draft || event.submissionStatus == .pending
        let isDraft = event.submissionStatus == .draft

        return EventListItemViewModel(
            id: event.id,
            title: event.title,
            subtitle: subtitle.sizing(withNumberOfLines: 0),
            detail: detail?.sizing(withNumberOfLines: 0),
            cardSubtitle: location?.sizing(withNumberOfLines: 0),
            cardDetail: creationDate.sizing(withNumberOfLines: 0),
            image: image,
            selectable: selectable,
            isDraft: isDraft)
    }

    public init() {}

    /// The event's date of creation as a relative string, e.g. "Today 10:44"
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM"
        return RelativeDateFormatter(dateFormatter: formatter,
                                     timeFormatter: DateFormatter.preferredTimeStyle,
                                     separator: ", ")
    }()

}
