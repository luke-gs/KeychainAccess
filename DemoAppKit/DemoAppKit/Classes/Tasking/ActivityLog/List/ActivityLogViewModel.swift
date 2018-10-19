//
//  ActivityLogViewModel.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

/// View model for the main Activity Log view controller (the one in the tab bar)
public class ActivityLogViewModel: DatedActivityLogViewModel {

    public override init() {
        super.init()
        updateData()
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        let vc = ActivityLogViewController(viewModel: self)
        delegate = vc
        return vc
    }

    /// Update the task list
    public func updateData() {
        // TODO: fetch from network
        let viewModels = [
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 28),
                                     title: "At incident",
                                     subtitle: "Assault  •  PS20180615027"),
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 24),
                                     title: "Proceeding",
                                     subtitle: "Assault  •  PS20180615027"),
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 17),
                                     title: "On air",
                                     subtitle: "Assault  •  PS20180615027"),
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 14),
                                     title: "Finalise incident",
                                     subtitle: "Traffic Crash  •  PS20180615020"),
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 02),
                                     title: "Submit event",
                                     subtitle: "EV105-20181506"),
            ActivityLogItemViewModel(dotFillColor: .primaryGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 9).adding(minutes: 40),
                                     title: "Search person name: White, Natasha",
                                     subtitle: "J. Chieng")
        ]

        sections = sortedSectionsByDate(from: viewModels)
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Activity Log", comment: "Activity Log navigation title")
    }

    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }

    override open func noContentSubtitle() -> String? {
        return nil
    }

}
