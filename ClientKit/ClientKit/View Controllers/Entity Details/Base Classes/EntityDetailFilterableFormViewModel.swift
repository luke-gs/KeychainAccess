//
//  EntityDetailFilterableFormViewModel.swift
//  ClientKit
//
//  Created by Megan Efron on 8/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import MPOLKit

/// Abstract subclass of `EntityDetailFormViewController` that provides filtering support.
/// Abstract subclass of `EntityDetailFormViewController` that provides filtering support.
open class EntityDetailFilterableFormViewModel: EntityDetailFormViewModel, FilterViewControllerDelegate {
    
    // MARK: - Overrides
    
    /// Flag representing if filters have been applied.
    open var filterApplied: Bool {
        MPLRequiresConcreteImplementation()
    }
    
    /// The options list for the `FilterViewController`.
    open var filterOptions: [FilterOption] {
        MPLRequiresConcreteImplementation()
    }
    
    /// The implementation of `FilterViewControllerDelegate`
    open func filterViewControllerDidFinish(_ controller: FilterViewController, applyingChanges: Bool) {
        MPLRequiresConcreteImplementation()
    }
    
    // MARK: - Lifecycle
    
    /// The filter bar button item
    public let filterButton: FilterBarButtonItem = FilterBarButtonItem(target: nil, action: nil)
    
    public override init() {
        super.init()
        filterButton.isActive = filterApplied
        filterButton.target = self
        filterButton.action = #selector(filterItemDidSelect(_:))
    }
    
    // MARK: - EntityDetailFormViewModel
    
    open override var rightBarButtonItems: [UIBarButtonItem]? {
        filterButton.isActive = filterApplied
        return [filterButton]
    }
    
    @objc public func filterItemDidSelect(_ item: UIBarButtonItem) {
        let filterVC = FilterViewController(options: filterOptions)
        filterVC.title = NSLocalizedString("Filter \(title ?? "")", comment: "")
        filterVC.delegate = self
        delegate?.presentPopover(filterVC, barButton: item, animated: true)
    }
    
}
