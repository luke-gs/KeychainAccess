//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.

import PublicSafetyKit

public extension UserStorage {
    public static let storedEventsKey = "StoredEventsKey"
}

public protocol EventsManagerDelegate: class {
    func eventsManagerDidUpdate(_ eventsManager: EventsManager)
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

    // MARK: - Draftable Items

    public var draftItems: [Draftable] {
        return displayables.compactMap { EventDraftable(displayable: $0) }
    }

    public func deleteDraftItem(at index: Int) {
        if let event = events[ifExists: index] {
            try? remove(for: event.id)
        }
    }
}

private class EventDraftable: Draftable {

    private var displayable: EventListDisplayable

    public var id: String {
        return displayable.id
    }

    public var title: String? {
        return displayable.title
    }

    public var subtitle: String? {
        return displayable.subtitle
    }

    public var detail: String? {
        /// The event's date of creation as a relative string, e.g. "Today 10:44"
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "dd/MM"
        let customFormatter = RelativeDateFormatter(dateFormatter: formatter, timeFormatter: DateFormatter.preferredTimeStyle, separator: ", ")
        return customFormatter.string(from: displayable.creationDate)
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
        return displayable.status == .queued ? .queued : .draft
    }

    init(displayable: EventListDisplayable) {
        self.displayable = displayable
    }

}
