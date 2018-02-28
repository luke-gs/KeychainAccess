//
//  PatrolAreaListViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

public protocol PatrolAreaListViewModelDelegate: class {
    func patrolAreaListViewModel(_ viewModel: PatrolAreaListViewModel, didSelectPatrolArea patrolArea: String?)
}

open class PatrolAreaListViewModel: DefaultSearchDisplayableViewModel {
    
    // MARK: - Properties
    
    public var selectedPatrolArea: String?
    public weak var delegate: PatrolAreaListViewModelDelegate?
    
    // MARK: - Setup
    
    public convenience init() {
        var items: [CustomSearchDisplayable] = []
        for patrolArea in CADStateManager.shared.patrolGroups() {
            if let title = patrolArea.title {
                let viewModel = PatrolAreaListItemViewModel(patrolArea: title)
                items.append(viewModel)
            }
        }
        
        self.init(items: items)
    }
    
    public required init(items: [CustomSearchDisplayable]) {
        // Sort items alphabetically by title
        let sorted = items.sorted(using: [SortDescriptor<CustomSearchDisplayable> { $0.title }])
        super.init(items: sorted)
        
        title = navTitle()
        hasSections = false
    }
    
    open func navTitle() -> String {
        return NSLocalizedString("Select Patrol Area", comment: "")
    }
    
    open func doneButtonText() -> String {
        return NSLocalizedString("Done", comment: "")
    }
    
    open func cancelButtonText() -> String {
        return NSLocalizedString("Cancel", comment: "")
    }
    
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Patrol Areas Found", comment: "")
    }
    
    public override func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? {
        if let selected = selectedPatrolArea {
            return searchable.title == selected ? ItemAccessory.checkmark : nil
        }
        
        return nil
    }
    
    public func doneTapped() {
        delegate?.patrolAreaListViewModel(self, didSelectPatrolArea: selectedPatrolArea)
    }
    
}
