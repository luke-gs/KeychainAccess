//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.

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

    // Mark: - DraftableManager

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
        return event.creationDateString
    }

    public var subtitle: String? {
        if let locationReport = event.reports.first(where: {$0 is DefaultLocationReport}) {
            return ((locationReport as! DefaultLocationReport).eventLocation?.addressString ?? "Location Unknown")
        }
        return nil
    }

    public var status: DraftableStatus {
        return event.displayable?.status == .queued ? .queued : .draft
    }

    init(event: Event) {
        self.event = event
    }

}
