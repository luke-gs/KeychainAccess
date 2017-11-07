//
//  IncidentNarrativeViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentNarrativeViewModel: CADFormCollectionViewModel<ActivityLogItemViewModel> {
    
    public override init() {
        super.init()
        sections = dummyData
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> IncidentNarrativeViewController {
        return IncidentNarrativeViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var dummyData: [CADFormCollectionSectionViewModel<ActivityLogItemViewModel>] = {
        return [
            CADFormCollectionSectionViewModel(title: "3 New Updates",
                                              items: [
                                                ActivityLogItemViewModel(dotFillColor: .white,
                                                                               dotStrokeColor: #colorLiteral(red: 1, green: 0.8, blue: 0.003921568627, alpha: 1),
                                                                               timestamp: "10:30",
                                                                               title: "Incident Details Updated",
                                                                               subtitle: "Dispatch"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "10:30",
                                                                               title: "Status: At Incident [Assault - AS4205]",
                                                                               subtitle: "P24 (2) @ 188 Smith Street, Fitzroy VIC 3066"
                                                ),
                                                      ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1),
                                                                               dotStrokeColor: .clear,
                                                                               timestamp: "10:24",
                                                                               title: "Status: Proceeding [Assault - AS4205]",
                                                                               subtitle: "P24 (2)"
                                                )
                ]),
            CADFormCollectionSectionViewModel(title: "Read",
                                              items: [
                                                ActivityLogItemViewModel(dotFillColor: #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8509803922, alpha: 1),
                                                                         dotStrokeColor: .clear,
                                                                         timestamp: "10:20",
                                                                         title: "Status: Proceeding [Assault - AS4205]",
                                                                         subtitle: "P12 (1)"
                                                ),
                                                ActivityLogItemViewModel(dotFillColor: .white,
                                                                               dotStrokeColor: #colorLiteral(red: 1, green: 0.8, blue: 0.003921568627, alpha: 1),
                                                                               timestamp: "10:18",
                                                                               title: "Incident Details Updated",
                                                                               subtitle: "Dispatch"
                                                ),
                                                ActivityLogItemViewModel(dotFillColor: .white,
                                                                         dotStrokeColor: #colorLiteral(red: 1, green: 0.8, blue: 0.003921568627, alpha: 1),
                                                                         timestamp: "10:17",
                                                                         title: "Incident Details Updated",
                                                                         subtitle: "Dispatch"
                                                ),
                                                ActivityLogItemViewModel(dotFillColor: .white,
                                                                         dotStrokeColor: #colorLiteral(red: 1, green: 0.8, blue: 0.003921568627, alpha: 1),
                                                                         timestamp: "10:14",
                                                                         title: "Priority updated to P1",
                                                                         subtitle: "Dispatch"
                                                ),
                                                ActivityLogItemViewModel(dotFillColor: .white,
                                                                         dotStrokeColor: #colorLiteral(red: 1, green: 0.8, blue: 0.003921568627, alpha: 1),
                                                                         timestamp: "10:12",
                                                                         title: "Incident Created",
                                                                         subtitle: "Dispatch"
                                                ),
                                                
                                                
                ])
        ]
    }()
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Narrative", comment: "Narrative sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Activity Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }
    

}
