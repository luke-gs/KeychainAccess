//
//  ResourceActivityLogViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceActivityLogViewModel: CADFormCollectionViewModel<ActivityLogItemViewModel> {
    /// Create the view controller for this view model
    public func createViewController() -> ResourceActivityLogViewController {
        return ResourceActivityLogViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var data: [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "Friday July 15, 2017",
                                              items: [ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.9996698499, green: 0.2299259305, blue: 0.1864263117, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "10:27",
                                                                               title: "Duress Triggered",
                                                                               subtitle: "P08 (2) @ 57 Bell Street, Fitzroy VIC 3066"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: .white,
                                                                               dotStrokeColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                               timestamp: "10:20",
                                                                               title: "Search: Person (Huish, Joseph)",
                                                                               subtitle: "P08 (2) @ 57 Bell Street, Fitzroy VIC 3066"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.5207516551, green: 0.5253924131, blue: 0.5512865186, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "10:16",
                                                                               title: "Status: At Incident (Domestic Violence #AS4203)",
                                                                               subtitle: "P08 (2) @ 57 Bell Street, Fitzroy VIC 3066"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.5207516551, green: 0.5253924131, blue: 0.5512865186, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "10:05",
                                                                               title: "Status: Proceeding (Domestic Violence #AS4203)",
                                                                               subtitle: "P08 (2) @ Richmond Station, 217 Church Street, Richmond VIC 3121"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.4, green: 0.6745098039, blue: 0.3568627451, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "08:04",
                                                                               title: "Status: At Station",
                                                                               subtitle: "P08 (2) @ Richmond Station, 217 Church Street, Richmond VIC 3121"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: .white,
                                                                                 dotStrokeColor: #colorLiteral(red: 0.4, green: 0.6745098039, blue: 0.3568627451, alpha: 1),
                                                                                 timestamp: "07:57",
                                                                                 title: "Status: Booked On",
                                                                                 subtitle: "Dean McRae and Sarah Worrall  @ Richmond Station, 217 Church Street, Richmond VIC 3121"
                                                )])
        ]
    }()
    
    // MARK: - Override
    
    override open func sections() -> [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>] {
        return data
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Activity Log", comment: "Activity Log sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }

}
