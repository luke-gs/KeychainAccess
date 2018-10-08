//
//  NarrativeViewModel.swift
//  DemoAppKit
//
//  Created by Campbell Graham on 12/9/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Abstract base class for the view model for Narrative (inside Incidents, Broadcasts etc.)
open class NarrativeViewModel: DatedActivityLogViewModel, TaskDetailsViewModel {
    
    open func createViewController() -> TaskDetailsViewController {
        let vc = NarrativeViewController(viewModel: self)
        self.delegate = vc
        return vc
    }

    open func reloadFromModel(_ model: CADTaskListItemModelType) {
        MPLRequiresConcreteImplementation()
    }

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
