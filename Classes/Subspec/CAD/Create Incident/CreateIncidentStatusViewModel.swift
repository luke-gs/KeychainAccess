//
//  CreateIncidentStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for the status section in the create incident screen
open class CreateIncidentStatusViewModel: CADStatusViewModel {

    /// The current status
    open var currentStatus: ResourceStatusType? {
        if let selectedIndexPath = selectedIndexPath {
            return statusForIndexPath(selectedIndexPath)
        }
        return nil
    }
    
    /// Init with sectioned statuses to display, and current selection
    public init(sections: [CADFormCollectionSectionViewModel<ManageCallsignStatusItemViewModel>],
                selectedStatus: ResourceStatusType) {
        super.init()
        
        self.sections = sections
        self.selectedIndexPath = indexPathForStatus(selectedStatus)
    }
    
    /// Create the view controller for this view model
    public func createViewController() -> CreateIncidentStatusViewController {
        let vc = CreateIncidentStatusViewController(viewModel: self)
        self.delegate = vc
        return vc
    }
    
    /// Attempt to select a new status
    open func setSelectedIndexPath(_ indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
    
    open func statusForIndexPath(_ indexPath: IndexPath) -> ResourceStatusType {
        return sections[indexPath.section].items[indexPath.item].status
    }
    
    open func indexPathForStatus(_ status: ResourceStatusType) -> IndexPath? {
        // Find the status in the section data
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item.status.isEqual(status) {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
    
    // MARK: - Override
    
    open override func navTitle() -> String {
        return "Initial Status"
    }
    
    /// Hide arrows
    open override func shouldShowExpandArrow() -> Bool {
        return false
    }
}
