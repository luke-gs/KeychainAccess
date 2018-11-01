//
//  ActionReportable.swift
//  DemoAppKit
//
//  Created by Trent Fitzgibbon on 2/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol ActionReportable: IncidentReportable {

    /// A weak reference to the additional action object
    var weakAdditionalAction: Weak<AdditionalAction> { get set }
}

extension ActionReportable {

    /// Convenience property to acccess the underlying weak object of the action
    public var additionalAction: AdditionalAction? {
        return weakAdditionalAction.object
    }
}

