//
//  InterventionOrderDetailViewController.swift
//  Pods
//
//  Created by Gridstone on 29/5/17.
//
//

import UIKit
import MPOLKit

class InterventionOrderDetailViewController: EventDetailViewController {
    
    /// The intervention order event.
    ///
    /// Setting this as any event that is not a intervention order sets the event
    /// to `nil`.
    open override var event: Event? {
        get { return super.event }
        set { super.event = newValue as? InterventionOrder }
    }
}
