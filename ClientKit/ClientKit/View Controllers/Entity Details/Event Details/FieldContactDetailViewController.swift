//
//  FieldContactDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 27/5/17.
//
//

import UIKit
import MPOLKit

open class FieldContactDetailViewController: EventDetailViewController {
    
    /// The field contact event.
    ///
    /// Setting this as any event that is not a field contact sets the event
    /// to `nil`.
    open override var event: Event? {
        get { return super.event }
        set { super.event = newValue as? FieldContact }
    }
}
