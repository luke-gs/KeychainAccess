//
//  EventLogOffInterupt.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import CoreKit
import PublicSafetyKit

class EventLogOffInterupt: LogOffInterruptable {

    var eventsManager: EventsManager

    /// Closure to display events as this interrupt has no concept of presentation.
    var showEvents: (() -> Void)?

    init(eventsManager: EventsManager) {
        self.eventsManager = eventsManager
    }

    func shouldContinueLogOff() -> Promise<Bool> {
        return Promise { seal in
            let draftCount = eventsManager.draftEvents().count
            let unsubmittedCount = eventsManager.unsubmittedEvents().count
            guard draftCount > 0 || unsubmittedCount > 0 else {
                seal.fulfill(true)
                return
            }

            let viewEventsButton = DialogAction(title: NSLocalizedString("View Events", comment: ""), style: .default, handler: { [weak self] (_) in
                self?.showEvents?()
                seal.fulfill(false)
            })

            let continueButton = DialogAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: { (_) in
                seal.fulfill(true)
            })


            var title = "You still have "

            if draftCount > 0 {
                title +=  String.localizedStringWithFormat(NSLocalizedString("%d Draft Event(s)", comment: ""), draftCount)
                if unsubmittedCount > 0 {
                    title += " and "
                }

            }

            if unsubmittedCount > 0 {
                title +=  String.localizedStringWithFormat(NSLocalizedString("%d Unsubmitted Event(s)", comment: ""), unsubmittedCount)
            }

            title += ". These will be saved until your next session."

            let alertController = PSCAlertController(title: "Before You log off", message: title, image: nil)
            alertController.addAction(viewEventsButton)
            alertController.addAction(continueButton)
            AlertQueue.shared.add(alertController)
        }
    }

}
