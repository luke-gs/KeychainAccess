//
//  IncidentAssociationsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class IncidentAssociationsViewModel: CADFormCollectionViewModel<EntitySummaryDisplayable> {
    /// Create the view controller for this view model
    public func createViewController() -> IncidentAssociationsViewController {
        return IncidentAssociationsViewController(viewModel: self)
    }
    
    /// Lazy var for creating view model content
    private lazy var data: [CADFormCollectionSectionViewModel<EntitySummaryDisplayable>] = {
        return [
            CADFormCollectionSectionViewModel(title: "4 People",
                                              items: [
                                                IncidentPersonViewModel.init(category: "DS1",
                                                                             initials: "JC",
                                                                             title: "Citizen, John R.",
                                                                             detail1: "08/05/87 (29 Male)",
                                                                             detail2: "8 Catherine Street, Southbank VIC 3006",
                                                                             alertColor: .red,
                                                                             badge: 0),
                                                IncidentPersonViewModel.init(category: "DS1",
                                                                             initials: "NK",
                                                                             title: "Kim, Nari S.",
                                                                             detail1: "04/11/92 (24 Female)",
                                                                             detail2: "23 Somerset Street, Richmond VIC 3121",
                                                                             alertColor: nil,
                                                                             badge: 0),
                                                IncidentPersonViewModel.init(category: "DS1",
                                                                             initials: "TK",
                                                                             title: "Lazeron, Timo K.",
                                                                             detail1: "27/02/1998 (29 Male)",
                                                                             detail2: "27 Corsair Street, Richmond VIC 3121",
                                                                             alertColor: .blue,
                                                                             badge: 0),
                                                IncidentPersonViewModel.init(category: "DS1",
                                                                             initials: "RW",
                                                                             title: "Wang, Rocky T.",
                                                                             detail1: "23/09/81 (35 Male)",
                                                                             detail2: "302 Chandler Road, Keysborough VIC 3173",
                                                                             alertColor: nil,
                                                                             badge: 0)
                ])
        ]
    }()
    
    // MARK: - Override
    
    override open func sections() -> [CADFormCollectionSectionViewModel<EntitySummaryDisplayable>] {
        return data
    }
    
    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Associations", comment: "Associations sidebar title")
    }
    
    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Associations Found", comment: "")
    }
    
    override open func noContentSubtitle() -> String? {
        return nil
    }

}
