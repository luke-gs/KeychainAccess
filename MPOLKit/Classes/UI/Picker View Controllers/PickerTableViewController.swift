//
//  PickerTableViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 15/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate let cellID = "CellID"


/// A type that can be picked from a list.
///
/// Types that conform to the `Pickable` protocol can be selected from a list,
/// and should also conform to `Hashable`. This is not a protocol requirement,
/// however, to avoid limiting the protocol to generic type constraints.
public protocol Pickable {
    
    /// The title for presentation in a picking UI.
    var title: String?    { get }
    
    /// An additional subtitle description.
    var subtitle: String? { get }
    
}


/// A `Pickable` type that allows a custom searching.
public protocol CustomSearchPickable: Pickable {
    
    func contains(_ searchText: String) -> Bool
    
}


/// A table view for picking general items from a list.
///
/// `PickerTableViewController` presents items of a generic type that conforms
/// to `Pickable` and `Hashable`, and can be configured for single and multiple
/// selection modes.
/// 
/// When there are ten or more items in the list, the picker automatically
/// presents a search bar to allow easy filtering through the list. This can be
/// manually disabled if required.
open class PickerTableViewController<T>: FormSearchTableViewController where T: Pickable, T: Hashable {
    
    // MARK: - Public properties
    
    /// An array of items for selection in the picker.
    open var items: [T] = [] {
        didSet {
            setSearchBarHidden(items.count < 10, animated: false)
            updateFilter()
        }
    }
    
    
    /// The current selected items from the list.
    ///
    /// The default is none.
    open var selectedItems: Set<T> = [] {
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
                for (index, item) in filteredItems.enumerated() {
                    if itemsChangingSelection.contains(item) {
                        indexPathsToReload.append(IndexPath(row: index, section: 0))
                    }
                }
            } else {
                let hasNoSection = noItemTitle != nil
                if hasNoSection && (oldValue.isEmpty || selectedItems.isEmpty) {
                    indexPathsToReload.append(IndexPath(row: 0, section: 0))
                }
                
                let section = hasNoSection ? 1 : 0
                for (index, item) in items.enumerated() {
                    if itemsChangingSelection.contains(item) {
                        indexPathsToReload.append(IndexPath(row: index, section: section))
                    }
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
    
    
    /// An update handler to fire when the selection changes.
    ///
    /// This closure is only called on user-interaction based changes, much like delegate
    /// callbacks.
    open var selectionUpdateHandler: ((Set<T>?) -> Void)?
    
    
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
    
    private var filteredItems: [T]? {
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
        
        preferredContentSize = CGSize(width: 320.0, height: 435.0)
        clearsSelectionOnViewWillAppear = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(applyCurrentTheme), name: .ThemeDidChange, object: nil)
        applyCurrentTheme()
    }
    
    public convenience init(style: UITableViewStyle, items: [T]) {
        self.init(style: style)
        self.items = items
        setSearchBarHidden(items.count < 10, animated: false)
        updateFilter()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.estimatedRowHeight = 44.0
        searchBar.text = searchTerm
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { 
            self.setSearchBarHidden(false, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.setSearchBarHidden(true, animated: true)
        }
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
    
    
    // MARK: - UITableViewDataSource methods
    
    @objc(numberOfSectionsInTableView:) // Workaround. See: http://stackoverflow.com/questions/39416385/swift-3-objc-optional-protocol-method-not-called-in-subclass
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
        
        if let item = displayItem(at: indexPath) {
            cell.textLabel?.text       = item.title
            cell.detailTextLabel?.text = item.subtitle
            isSelected = selectedItems.contains(item)
        } else {
            cell.textLabel?.text       = noItemTitle
            cell.detailTextLabel?.text = nil
            isSelected = selectedItems.isEmpty
        }
        
        if #available(iOS 10, *) {
            cell.textLabel?.adjustsFontForContentSizeCategory = true
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        }
        
        cell.textLabel?.numberOfLines = 0
    
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        let isSelected: Bool
        
        if let item = displayItem(at: indexPath) {
            isSelected = selectedItems.contains(item)
        } else {
            isSelected = selectedItems.isEmpty
        }
        
        cell.textLabel?.alpha = isSelected ? 1.0 : 0.5
    }
    
    @objc(tableView:didSelectRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        manualSelectionUpdate = true
        
        func updateCurrentCell(forCheck check: Bool) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = check ? .checkmark : .none
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                self.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
            }
        }
        
        var reloadIndexPaths: [IndexPath] = []
        
        let noSectionShowing = noItemTitle != nil && filteredItems == nil
        
        if let item = displayItem(at: indexPath) {
            if allowsMultipleSelection {
                let isSelected = selectedItems.remove(item) == nil
                if isSelected {
                    selectedItems.insert(item)
                }
                updateCurrentCell(forCheck: isSelected)
                
                if (selectedItems.isEmpty || (isSelected && selectedItems.count == 1)) && noSectionShowing {
                    reloadIndexPaths.append(IndexPath(row: 0, section: 0))
                }
            } else {
                if let oldIndexPath = self.indexPath(for: selectedItems.first) {
                    reloadIndexPaths.append(oldIndexPath)
                }
                
                selectedItems = [item]
                
                updateCurrentCell(forCheck: true)
            }
        } else if noSectionShowing {
            // "No" item selected. Filter not showing.
            
            let selectedItemCount = selectedItems.count
            
            if selectedItemCount > 0 {
                let oldSelectedItems = selectedItems
            
                selectedItems = []
                updateCurrentCell(forCheck: true)
            
                reloadIndexPaths.reserveCapacity(selectedItemCount)
                
                for (index, item) in items.enumerated() {
                    if oldSelectedItems.contains(item) {
                        reloadIndexPaths.append(IndexPath(row: index, section: 1))
                    }
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

    private func displayItem(at indexPath: IndexPath) -> T? {
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
    
    private func indexPath(for displayItem: T?) -> IndexPath? {
        if let filteredItems = self.filteredItems {
            if let item = displayItem,
                let index = filteredItems.index(of: item) {
                return IndexPath(row: index, section: 0)
            } else {
                return nil
            }
        } else {
            if let displayItem = displayItem {
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
                    if $0.title?.localizedCaseInsensitiveContains(term) ?? false {
                        return true
                    }
                    if $0.subtitle?.localizedCaseInsensitiveContains(term) ?? false {
                        return true
                    }
                    if ($0 as? CustomSearchPickable)?.contains(term) ?? false {
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
