//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
import PublicSafetyKit

public extension UserStorage {
    public static let storedEventsKey = "StoredEventsKey"
}

/// Manages the list of events
final public class EventsManager {

    public weak var delegate: EventsManagerDelegate?

    /// The builder used to create events and displayables
    public var eventBuilder: EventBuilding

    /// The currently stored user events
    public private(set) var events: [Event] = []

    public required init(eventBuilder: EventBuilding) {
        self.eventBuilder = eventBuilder
        loadEvents()
    }

    /// Return the current events as displayables
    public var displayables: [EventListDisplayable] {
        return events.map { event in
            return eventBuilder.displayable(for: event)
        }
    }

    public func create(eventType: EventType) throws -> Event? {
        let event = eventBuilder.createEvent(for: eventType)
        events.append(event)

        // Store latest events array to disk
        try storeAndNotify()

        return event
    }

    public func update(for id: String) throws {
        // Store latest events array to disk
        try storeAndNotify()
    }

    public func remove(for id: String) throws {
        events.removeAll { event -> Bool in
            return event.id == id
        }

        // Store latest events array to disk
        try storeAndNotify()
    }

    /// Return the event for a given id
    public func event(for id: String) -> Event? {
        return events.first(where: { $0.id == id })
    }

    // MARK: - Persistence

    /// Persist the latest version of events, and notify delegate
    private func storeAndNotify() throws {
        try storeEvents()
        delegate?.eventsManagerDidUpdate(self)
    }

    /// Store the current events
    private func storeEvents() throws {
        // Store events using retain storage, so it persists across logins
        try UserSession.current.userStorage?.add(object: events, key: UserStorage.storedEventsKey, flag: .retain)
    }

    /// Load any persisted events
    private func loadEvents() {
        events = UserSession.current.userStorage?.retrieve(key: UserStorage.storedEventsKey) ?? []
    }

}

public protocol EventsManagerDelegate: class {
    func eventsManagerDidUpdate(_ eventsManager: EventsManager)
}
