//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
import PublicSafetyKit
/// Manages the list of events
final public class EventsManager {

    public var eventBucket: ObjectBucket<Event> = ObjectBucket<Event>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

    public var displayableBucket: ObjectBucket<EventListDisplayable> = ObjectBucket<EventListDisplayable>(directory: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)

    public var eventBuilder: EventBuilding

    public required init(eventBuilder: EventBuilding) {
        self.eventBuilder = eventBuilder
    }

    public func create(eventType: EventType) -> Event? {
        let eventDisplayableTuple = eventBuilder.createEvent(for: eventType)

        let event = eventDisplayableTuple.event
        let displayable = eventDisplayableTuple.displayable

        event.displayable = displayable

        displayableBucket.add(displayable)
        eventBucket.add(event)

        return event
    }

    //add
    private func add(event: Event) {
        eventBucket.add(event)
    }

    //remove
    public func remove(event: Event) {
        eventBucket.remove(event)
    }

    public func remove(for id: String) {
        guard let event = self.event(for: id), let displayable = event.displayable else { return }
        eventBucket.remove(event)
        displayableBucket.remove(displayable)
    }

    //utility
    public func event(for id: String) -> Event? {
        return eventBucket.objects?.first(where: {$0.id == id})
    }

    // Mark: - Draftable Items

    public var draftItems: [Draftable] {
        return eventBucket.objects?.compactMap { EventDraftable(event: $0) } ?? []
    }

    public func deleteDraftItem(at index: Int, with id: String) {
        remove(for: id)
    }
}

fileprivate class EventDraftable: Draftable {

    private var event: Event

    public var id: String {
        return event.id
    }

    public var title: String? {
        return event.displayable?.title
    }

    public var detail: String? {
        /// The event's date of creation as a relative string, e.g. "Today 10:44"
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM"
        let customFormatter = RelativeDateFormatter(dateFormatter: formatter, timeFormatter: DateFormatter.preferredTimeStyle, separator: ", ")
        return customFormatter.string(from: event.creationDate)
    }

    public var subtitle: String? {
        if let locationReport = event.reports.first(where: {$0 is DefaultLocationReport}) {
            return ((locationReport as! DefaultLocationReport).eventLocation?.addressString ?? "Location Unknown")
        }
        return nil
    }

    public var listIconImage: UIImage? {
        let isDark = ThemeManager.shared.currentInterfaceStyle == .dark

        var image: UIImage?

        switch status {
        case .draft:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .black : .white, circleColor: isDark ? .white : .black, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        case .queued:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .white : .black, circleColor: isDark ? .darkGray : .disabledGray, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        }

        return image
    }

    public var status: DraftableStatus {
        return event.displayable?.status == .queued ? .queued : .draft
    }

    init(event: Event) {
        self.event = event
    }

}
