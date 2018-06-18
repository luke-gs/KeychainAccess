//
//  PatrolAreaListViewModel.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit
import PromiseKit

public protocol PatrolAreaListViewModelDelegate: class {
    func patrolAreaListViewModel(_ viewModel: PatrolAreaListViewModel, didSelectPatrolArea patrolArea: String?)
}

open class PatrolAreaListViewModel: DefaultSearchDisplayableViewModel {
    
    // MARK: - Properties
    
    public var selectedPatrolArea: String?
    public weak var selectionDelegate: PatrolAreaListViewModelDelegate?
    
    // MARK: - Setup
    
    public convenience init() {
        var items: [CustomSearchDisplayable] = []
        let patrolAreas = CADStateManager.shared.manifestEntries(for: .patrolGroup)
        for patrolArea in patrolAreas.sorted(using: [SortDescriptor<ManifestEntry> { $0.title }]) {
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
    
    open func reloadItems() {
        var items: [CustomSearchDisplayable] = []
        let patrolAreas = CADStateManager.shared.manifestEntries(for: .patrolGroup)
        for patrolArea in patrolAreas.sorted(using: [SortDescriptor<ManifestEntry> { $0.title }]) {
            if let title = patrolArea.title {
                let viewModel = PatrolAreaListItemViewModel(patrolArea: title)
                items.append(viewModel)
            }
        }
        self.items = items
    }
    
    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let vc = PatrolAreaListViewController(viewModel: self)
        return vc
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
    
    public override func searchAction() -> Promise<Void>? {
        return nil
    }
    
    public func indexOfSelectedItem() -> Int? {
        return items.indexes(where: { $0.title == selectedPatrolArea }).first
    }
    
    public override func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? {
        if let selected = selectedPatrolArea {
            return searchable.title == selected ? ItemAccessory.checkmark : nil
        }
        
        return nil
    }
    
    public func doneTapped() {
        selectionDelegate?.patrolAreaListViewModel(self, didSelectPatrolArea: selectedPatrolArea)
    }
    
}
