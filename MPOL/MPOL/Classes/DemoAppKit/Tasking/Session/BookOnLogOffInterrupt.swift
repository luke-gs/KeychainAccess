//
//  BookOnLogOffInterrupt.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import PromiseKit
import CoreKit

/// Simple interrupt that stops a user for logging off if they're currently booked on
public struct BookOnLogOffInterrupt: LogOffInterruptable {
    public func shouldContinueLogOff() -> Promise<Bool> {
        return Promise<Bool> { seal in
            if CADStateManager.shared.lastBookOn != nil {
                AlertQueue.shared.addSimpleAlert(title: NSLocalizedString("Unable to Log Out", comment: ""),
                                                 message: NSLocalizedString("You must book off before logging out.", comment: ""))
                seal.fulfill(false)
            } else {
                seal.fulfill(true)
            }

        }
    }
}
