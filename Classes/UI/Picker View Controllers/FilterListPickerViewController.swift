//
//  FilterListPickerViewController.swift
//  MPOLKit_Example
//
//  Created by Rod Brown on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

fileprivate let cellID = "CellID"


/// Temp Workaround: A type-erased, non-pickable compliant version of the `PickerTableViewController`.
///
/// TODO: Create an alternative type "AnyPickable" which conforms to Pickable and Hashable, making
/// this class obsolete.
internal class FilterListPickerViewController: FormSearchTableViewController {

    // MARK: - Public properties
    
    /// An array of items for selection in the picker.
    open var items: [AnyHashable] = [] {
        didSet {
            setSearchBarHidden(items.count < 10, animated: false)
            updateFilter()
        }
    }
    
    
    /// The current selected items from the list.
    ///
    /// The default is none.
    open var selectedItems: Set<AnyHashable> = [] {
        didSet {
            guard manualSelectionUpdate == false, let tableView = self.tableView else { return }
            
            // Form a symmetric difference - a set containing those being lost, or those being gained.
            // If there are none changing, that's cool, no updates.
            let itemsChangingSelection = oldValue.symmetricDifference(selectedItems)
            if itemsChangingSelection.isEmpty { return }
            
            
            // Find the paths to reload.
            // Note that we do this manually via one pass through the arrays to optimize, or this could
            // become an O(N^2) operation, and so for long lists (1000+) the penalty may be huge, especially
            // if a fair amount of selected items are at the end of the list.
            // We iterate once the correct array, and use the smaller change set for contains (O(1)) operation.
            var indexPathsToReload: [IndexPath] = []
            
            if let filteredItems = self.filteredItems {
                for (index, item) in filteredItems.enumerated() where itemsChangingSelection.contains(item) {
                    indexPathsToReload.append(IndexPath(row: index, section: 0))
                }
            } else {
                let hasNoSection = noItemTitle != nil
                if hasNoSection && (oldValue.isEmpty || selectedItems.isEmpty) {
                    indexPathsToReload.append(IndexPath(row: 0, section: 0))
                }
                
                let section = hasNoSection ? 1 : 0
                for (index, item) in items.enumerated() where itemsChangingSelection.contains(item) {
                    indexPathsToReload.append(IndexPath(row: index, section: section))
                }
            }
            
            if indexPathsToReload.isEmpty == false {
                tableView.reloadRows(at: indexPathsToReload, with: .none)
            }
        }
    }
    
    
    /// A boolean value indicating whether multiple items can be selected in the list.
    ///
    /// The default is false.
    open var allowsMultipleSelection: Bool = false {
        didSet {
            if allowsMultipleSelection == oldValue { return }
            
            let selectedItems = self.selectedItems
            if selectedItems.count > 1 && allowsMultipleSelection == false {
                
                if let firstSelectedItem = items.first(where: { selectedItems.contains($0) }) {
                    self.selectedItems = [firstSelectedItem]
                } else {
                    self.selectedItems.removeAll()
                }
            }
        }
    }
    
    open var allowsNoSelection: Bool = true {
        didSet {
            if allowsNoSelection == false && noItemTitle != nil {
                noItemTitle = nil
            }
        }
    }
    
    
    /// An update handler to fire when the selection changes.
    ///
    /// This closure is only called on user-interaction based changes, much like delegate
    /// callbacks.
    open var selectionUpdateHandler: ((Set<AnyHashable>) -> Void)?
    
    /// A completion handler to fire when closing.
    open var finishUpdateHandler: ((Set<AnyHashable>) -> Void)?
    
    
    /// The title for an item representing no selection.
    ///
    /// The default is `nil`, meaning no option is provided for "no selection".
    open var noItemTitle: String? {
        didSet {
            guard noItemTitle != oldValue,
                let tableView = self.tableView else {
                    return
            }
            
            if noItemTitle != nil && oldValue != nil {
                tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    
    /// The current search term.
    ///
    /// This is automatically set to `nil` when the search bar is hidden.
    open var searchTerm: String? {
        didSet {
            if searchTerm == oldValue { return }
            
            searchBar.text = searchTerm
            updateFilter()
        }
    }
    
    
    open override func setSearchBarHidden(_ hidden: Bool, animated: Bool) {
        super.setSearchBarHidden(hidden, animated: animated)
        
        if hidden {
            searchTerm = nil
        }
    }
    
    
    // MARK: - Private properties
    
    private var filteredItems: [AnyHashable]? {
        didSet {
            if let filteredItems = self.filteredItems {
                if let oldValue = oldValue,
                    filteredItems == oldValue {
                    return
                }
            } else if oldValue == nil {
                return
            }
            
            tableView?.reloadData()
        }
    }
    
    private var manualSelectionUpdate: Bool = false
    
    
    // MARK: - Initializing
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
        
        clearsSelectionOnViewWillAppear = false
        wantsCalculatedContentHeight = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        applyCurrentTheme()
    }
    
    public convenience init(style: UITableViewStyle, items: [AnyHashable]) {
        self.init(style: style)
        self.items = items
        setSearchBarHidden(items.count < 10, animated: false)
        updateFilter()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.estimatedRowHeight = 44.0
        searchBar.text = searchTerm
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Scroll to the first selected index in the list.
        let selectedItems = self.selectedItems
        if selectedItems.isEmpty {
            if noItemTitle != nil {
                tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            }
            return
        }
        
        if let firstIndex = (filteredItems ?? items).index(where: { selectedItems.contains($0) }) {
            let section = filteredItems != nil || noItemTitle == nil ? 0 : 1
            
            tableView?.scrollToRow(at: IndexPath(row: firstIndex, section: section), at: .none, animated: false)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed || isMovingFromParentViewController {
            finishUpdateHandler?(selectedItems)
        }
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return noItemTitle != nil && filteredItems == nil ? 2 : 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredItemCount = filteredItems?.count {
            return filteredItemCount
        }
        
        if section == 0 && noItemTitle != nil {
            return 1
        }
        
        return items.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let isSelected: Bool
        
        if let item = pickableItem(at: indexPath) {
            let pickableItem = item as! Pickable
            cell.textLabel?.text       = pickableItem.title
            cell.detailTextLabel?.text = pickableItem.subtitle
            isSelected = selectedItems.contains(item)
        } else {
            cell.textLabel?.text       = noItemTitle
            cell.detailTextLabel?.text = nil
            isSelected = selectedItems.isEmpty
        }
        
        if let textLabel = cell.textLabel {
            textLabel.adjustsFontForContentSizeCategory = true
            textLabel.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
            textLabel.numberOfLines = 0
        }
        
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        let isSelected: Bool
        
        if let item = pickableItem(at: indexPath) {
            isSelected = selectedItems.contains(item)
        } else {
            isSelected = selectedItems.isEmpty
        }
        
        cell.textLabel?.alpha = isSelected ? 1.0 : 0.5
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        manualSelectionUpdate = true
        
        func updateCurrentCell(checked: Bool) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = checked ? .checkmark : .none
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                self.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
        
        var reloadIndexPaths: [IndexPath] = []
        
        let noSectionShowing = noItemTitle != nil && filteredItems == nil
        
        if let item = pickableItem(at: indexPath) {
            if allowsMultipleSelection {
                var isSelected = selectedItems.remove(item) == nil
                if isSelected || (allowsNoSelection == false && selectedItems.isEmpty) {
                    isSelected = true
                    selectedItems.insert(item)
                }
                
                updateCurrentCell(checked: isSelected)
                
                if (selectedItems.isEmpty || (isSelected && selectedItems.count == 1)) && noSectionShowing {
                    reloadIndexPaths.append(IndexPath(row: 0, section: 0))
                }
            } else {
                if let oldIndexPath = self.indexPath(for: selectedItems.first), oldIndexPath != indexPath {
                    reloadIndexPaths.append(oldIndexPath)
                }
                selectedItems = [item]
                
                updateCurrentCell(checked: true)
            }
        } else if noSectionShowing {
            // "No" item selected. Filter not showing.
            
            let selectedItemCount = selectedItems.count
            
            if selectedItemCount > 0 {
                let oldSelectedItems = selectedItems
                
                selectedItems = []
                updateCurrentCell(checked: true)
                
                reloadIndexPaths.reserveCapacity(selectedItemCount)
                
                for (index, item) in items.enumerated() where oldSelectedItems.contains(item) {
                    reloadIndexPaths.append(IndexPath(row: index, section: 1))
                }
            }
        }
        
        if reloadIndexPaths.isEmpty == false {
            tableView.reloadRows(at: reloadIndexPaths, with: .none)
        }
        
        manualSelectionUpdate = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectionUpdateHandler?(selectedItems)
    }
    
    
    // MARK: - Search bar delegate
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
    }
    
    
    // MARK: - Private methods
    
    private func pickableItem(at indexPath: IndexPath) -> AnyHashable? {
        if let filteredItems = filteredItems {
            if indexPath.section != 0 { return nil }
            
            return filteredItems[ifExists: indexPath.row]
        } else {
            let hasNoItemTitle = noItemTitle != nil
            
            if (hasNoItemTitle && indexPath.section != 1) || (hasNoItemTitle == false && indexPath.section != 0) {
                return nil
            }
            return items[ifExists: indexPath.row]
        }
    }
    
    private func indexPath(for pickableItem: AnyHashable?) -> IndexPath? {
        if let filteredItems = self.filteredItems {
            if let item = pickableItem,
                let index = filteredItems.index(of: item) {
                return IndexPath(row: index, section: 0)
            } else {
                return nil
            }
        } else {
            if let displayItem = pickableItem {
                if let index = items.index(of: displayItem) {
                    return IndexPath(row: index, section: noItemTitle == nil ? 0 : 1)
                } else {
                    return nil
                }
            } else if noItemTitle != nil {
                return IndexPath(row: 0, section: 0)
            } else {
                return nil
            }
        }
    }
    
    private func updateFilter() {
        if let searchText = self.searchTerm, searchText.isEmpty == false{
            let term = searchText.trimmingCharacters(in: .whitespaces)
            if term.isEmpty == false {
                filteredItems = items.filter {
                    let pickable = $0 as! Pickable
                    
                    if pickable.title?.localizedCaseInsensitiveContains(term) ?? false {
                        return true
                    }
                    if pickable.subtitle?.localizedCaseInsensitiveContains(term) ?? false {
                        return true
                    }
                    if (pickable as? CustomSearchPickable)?.contains(term) ?? false {
                        return true
                    }
                    return false
                    
                }
            } else {
                filteredItems = items
            }
        } else {
            filteredItems = nil
        }
    }
}
