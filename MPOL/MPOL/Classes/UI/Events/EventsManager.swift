//
//  EventsManager.swift
//  MPOLKit
//
//  Copyright © 2017 Gridstone. All rights reserved.

import PublicSafetyKit
import PromiseKit

public extension UserStorage {
    public static let storedEventsKey = "StoredEventsKey"
}

public protocol EventsManagerDelegate: class {
    func eventsManagerDidUpdate(_ eventsManager: EventsManager)
}

/// Manages the list of events
final public class EventsManager {

    public static let logOffInterruptIdentifier = "EventsManager"

    public weak var delegate: EventsManagerDelegate?

    /// The builder used to create events and displayables
    public var eventBuilder: EventBuilding

    /// The currently stored user events
    public private(set) var events: [Event] = []

    deinit {
        LogOffManager.shared.removeInterrupt(key: CADStateManagerCore.logOffInterruptIdentifier)
    }

    public required init(eventBuilder: EventBuilding) {
        self.eventBuilder = eventBuilder
        loadEvents()
        registerLogOffInterrupts()
    }

    /// Return the current events as displayables
    public var displayables: [EventListItemViewModelable] {
        return events.map { event in
            return eventBuilder.displayable(for: event)
        }
    }

    /// All draft events
    public func draftEvents() -> [Event] {
        return events.filter { $0.submissionStatus == .draft }
    }

    /// All events that are neither draft or submitted
    public func unsubmittedEvents() -> [Event] {
        return events.filter {
            switch $0.submissionStatus {
            case .pending, .failed:
                return true
            case .draft, .submitted, .sending:
                return false
            }
        }
    }

    public func create(eventType: EventType, incidentType: IncidentType?) throws -> Event? {
        let event = eventBuilder.createEvent(eventType: eventType, incidentType: incidentType)
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

    func registerLogOffInterrupts() {

        let draftEventsInterrupt: LogOffManager.LogOffInterrupt = { [weak self] in
            guard let self = self else { return Promise<Bool> { $0.fulfill(true) } }
            let draftCount = self.draftEvents().count
            let unsubmittedCount = self.unsubmittedEvents().count

            return Promise<Bool>.value(draftCount > 0 || unsubmittedCount > 0).then { result -> Promise<Bool> in
                if result {
                    return self.showLogoffWithEventsPrompt()
                } else {
                    return Promise<Bool>.value(false)
                }
            }
        }

        LogOffManager.shared.setInterrupt(draftEventsInterrupt, for: EventsManager.logOffInterruptIdentifier)
    }

    func showLogoffWithEventsPrompt() -> Promise<Bool> {
        return Promise<Bool> { seal in
            let draftCount = self.draftEvents().count
            let unsubmittedCount = self.unsubmittedEvents().count
            let viewEventsButton = DialogAction(title: NSLocalizedString("View Events", comment: ""), style: .default, handler: { (_) in
                // FromVC will become nil with a future refactor
                Director.shared.present(LandingScreen.tab(index: Screen.event.index()), fromViewController: UIViewController())
                seal.fulfill(true)
            })

            let continueButton = DialogAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (_) in
                seal.fulfill(false)
            })

            var title = NSLocalizedString("You still have ", comment: "")

            if draftCount > 0 {
                title +=  String.localizedStringWithFormat(NSLocalizedString("%d Draft Event(s)", comment: ""), draftCount)
                if unsubmittedCount > 0 {
                    title += NSLocalizedString(" and ", comment: "")
                }
            }

            if unsubmittedCount > 0 {
                title +=  String.localizedStringWithFormat(NSLocalizedString("%d Unsubmitted Event(s)", comment: ""), unsubmittedCount)
            }

            title += NSLocalizedString(". These will be saved until your next session.", comment: "")

            let alertController = PSCAlertController(title: NSLocalizedString("Before You log off", comment: ""), message: title, image: nil)
            alertController.addAction(viewEventsButton)
            alertController.addAction(continueButton)
            AlertQueue.shared.add(alertController)
        }
    }
}
