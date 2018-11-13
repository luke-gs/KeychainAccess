//
//  EventSummaryViewModel.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class EventSummaryViewModel {
    weak var event: Event?

    public init(event: Event) {
        self.event = event
    }
}
