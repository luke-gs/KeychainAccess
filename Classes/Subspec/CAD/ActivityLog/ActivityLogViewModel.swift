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
        return ActivityLogViewController(viewModel: self)
    }
    
    /// Update the task list
    public func updateData() {
        // TODO: fetch from network
        let viewModels = [
            ActivityLogItemViewModel(dotFillColor: .disabledGray,
                                     dotStrokeColor: .clear,
                                     timestamp: "10:30",
                                     date: Date(),
                                     title: "Status: At Incident [Assault - AS4205]",
                                     subtitle: "Jason Chieng, Herli Halim @ 188 Smith Street, Fitzroy VIC 3065"),
            ActivityLogItemViewModel(dotFillColor: .disabledGray,
                                     dotStrokeColor: .clear,
                                     timestamp: "10:24",
                                     date: Date(),
                                     title: "Status: Proceeding [Assault - AS4205]",
                                     subtitle: "Jason Chieng, Herli Halim"),
            ActivityLogItemViewModel(dotFillColor: .midGreen,
                                     dotStrokeColor: .clear,
                                     timestamp: "10:17",
                                     date: Date(),
                                     title: "Status: On Air",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .brightBlue,
                                     dotStrokeColor: .clear,
                                     timestamp: "10:14",
                                     date: Date(),
                                     title: "Incident: Finalise [Traffic Crash - AS4197]",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .white,
                                     dotStrokeColor: .brightBlue,
                                     timestamp: "10:02",
                                     date: Date(),
                                     title: "Event: Submit Event [Incident Report - EV105-160717]",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .white,
                                     dotStrokeColor: .brightBlue,
                                     timestamp: "09:40",
                                     date: Date(),
                                     title: "Event: Create Event [Incident Report - EV105-160717]",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
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
