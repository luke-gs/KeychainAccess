//
//  DisplayItemPickerViewController.swift
//  VCom
//
//  Created by Rod Brown on 15/07/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public protocol DisplayItem {
    
    var title: String?    { get }
    var subtitle: String? { get }
    
}

public protocol CustomSearchDisplayItem: DisplayItem {
    
    func contains(_ searchText: String) -> Bool
    
}


fileprivate let cellID = "CellID"

open class DisplayItemPickerViewController<T>: FormSearchTableViewController where T: DisplayItem, T: Hashable {
    
    open var searchTerm: String? {
        didSet {
            if searchTerm != oldValue {
                searchBar?.text = searchTerm
                updateFilter()
            }
        }
    }
    
    open var items: [T] = [] {
        didSet {
            setSearchBarHidden(items.count < 10, animated: false)
            updateFilter()
        }
    }
    
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
    
    open var selectionUpdateHandler: ((Set<T>?) -> Void)?
    
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
    
    open override func setSearchBarHidden(_ hidden: Bool, animated: Bool) {
        super.setSearchBarHidden(hidden, animated: animated)
        
        if hidden {
            searchTerm = nil
        }
    }
    
    
    private var filteredItems: [T]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    private var manualSelectionUpdate: Bool = false
    
    
    // MARK: - Initializing
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
        
        preferredContentSize = CGSize(width: 320.0, height: 435.0)
        
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
    
    
    // MARK: - UITableViewDataSource
    
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
    
    
    // MARK: - Table view delegate
    
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
                    if ($0 as? CustomSearchDisplayItem)?.contains(term) ?? false {
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
