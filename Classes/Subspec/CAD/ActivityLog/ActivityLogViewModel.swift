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
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 30),
                                     title: "Status: At Incident [Assault - AS4205]",
                                     subtitle: "Jason Chieng, Herli Halim @ 188 Smith Street, Fitzroy VIC 3065"),
            ActivityLogItemViewModel(dotFillColor: .disabledGray,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 24),
                                     title: "Status: Proceeding [Assault - AS4205]",
                                     subtitle: "Jason Chieng, Herli Halim"),
            ActivityLogItemViewModel(dotFillColor: .midGreen,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 17),
                                     title: "Status: On Air",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .brightBlue,
                                     dotStrokeColor: .clear,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 14),
                                     title: "Incident: Finalise [Traffic Crash - AS4197]",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .white,
                                     dotStrokeColor: .brightBlue,
                                     timestamp: Date().beginningOfDay.adding(hours: 10).adding(minutes: 02),
                                     title: "Event: Submit Event [Incident Report - EV105-160717]",
                                     subtitle: "Jason Chieng, Herli Halim @ 28 Wellington Street, Collingwood VIC 3066"),
            ActivityLogItemViewModel(dotFillColor: .white,
                                     dotStrokeColor: .brightBlue,
                                     timestamp: Date().beginningOfDay.adding(hours: 9).adding(minutes: 40),
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
