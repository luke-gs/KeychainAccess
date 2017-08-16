//
//  BailOrderDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 28/5/17.
//
//

import UIKit
import MPOLKit

open class BailOrderDetailViewController: EventDetailViewController {
    
    /// The bail order event.
    ///
    /// Setting this as any event that is not a bail order sets the event
    /// to `nil`.
    open override var event: Event? {
        get { return super.event }
        set { super.event = newValue as? BailOrder }
    }
}
