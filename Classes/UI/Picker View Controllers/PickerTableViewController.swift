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
/// Types that conform to the `Pickable` protocol can be selected from a list.
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
/// 
/// When there are ten or more items in the list, the picker automatically
/// presents a search bar to allow easy filtering through the list. This can be
/// manually disabled if required.
open class PickerTableViewController<T>: FormSearchTableViewController where T: Pickable {
    
    // MARK: - Public properties
    
    /// An array of items for selection in the picker.
    open var items: [T] = [] {
        didSet {
            setSearchBarHidden(items.count < 10, animated: false)
            updateFilter()
        }
    }
    
    
    /// The current selected item indexes from the list.
    ///
    /// The default is none.
    open var selectedIndexes: IndexSet = IndexSet() {
        didSet {
            guard manualSelectionUpdate == false, let tableView = self.tableView else { return }
            
            // Form a symmetric difference - a set containing those being lost, or those being gained.
            // If there are none changing, that's cool, no updates.
            let indexesChangingSelection = oldValue.symmetricDifference(selectedIndexes)
            if indexesChangingSelection.isEmpty { return }
            
            
            // Find the paths to reload.
            var indexPathsToReload: [IndexPath] = []
            
            if let filteredItems = self.filteredIndexes {
                for (row, index) in filteredItems.enumerated() where indexesChangingSelection.contains(index) {
                    indexPathsToReload.append(IndexPath(row: row, section: 0))
                }
            } else {
                let hasNoSection = noItemTitle != nil
                if hasNoSection && (oldValue.isEmpty || selectedIndexes.isEmpty) {
                    indexPathsToReload.append(IndexPath(row: 0, section: 0))
                }
                
                let section = hasNoSection ? 1 : 0
                
                for row in (0..<items.count) where indexesChangingSelection.contains(row) {
                    indexPathsToReload.append(IndexPath(row: row, section: section))
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
            
            let selectedItems = self.selectedIndexes
            if selectedItems.count > 1 && allowsMultipleSelection == false {
                
                if let firstSelectedItem = self.selectedIndexes.first {
                    self.selectedIndexes = [firstSelectedItem]
                } else {
                    self.selectedIndexes.removeAll()
                }
            }
        }
    }
    
    
    /// An update handler to fire when the selection changes.
    ///
    /// The parameters are the table view controller, and the indexes selected.
    ///
    /// This closure is only called on user-interaction based changes, much like delegate
    /// callbacks.
    open var selectionUpdateHandler: ((PickerTableViewController<T>, IndexSet) -> Void)?
    
    
    /// An update handler to fire when the view controller dismisses or is popped from
    /// a `UINavigationController` stack.
    ///
    /// The parameters are the table view controller, and the indexes selected.
    open var finishUpdateHandler: ((PickerTableViewController<T>, IndexSet) -> Void)?
    
    
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
    
    private var filteredIndexes: [Int]? {
        didSet {
            if let filteredItems = self.filteredIndexes {
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
        
        wantsCalculatedContentHeight = true
        
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
        
        guard let firstSelectedIndex = selectedIndexes.first else {
            if noItemTitle != nil {
                tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            }
            return
        }
        
        let firstSelectedRow: Int?
        let section: Int
        if let filteredIndexes = self.filteredIndexes {
            firstSelectedRow = filteredIndexes.index(of: firstSelectedIndex)
            section = 0
        } else {
            firstSelectedRow = firstSelectedIndex
            section = noItemTitle == nil ? 0 : 1
        }
        
        if let moveToRow = firstSelectedRow {
            tableView?.scrollToRow(at: IndexPath(row: moveToRow, section: section), at: .none, animated: false)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed || isMovingFromParentViewController {
            finishUpdateHandler?(self, selectedIndexes)
        }
    }
    
    
    // MARK: - UITableViewDataSource methods
    
    @objc(numberOfSectionsInTableView:) // Workaround. See: http://stackoverflow.com/questions/39416385/swift-3-objc-optional-protocol-method-not-called-in-subclass
    open func numberOfSections(in tableView: UITableView) -> Int {
        return noItemTitle != nil && filteredIndexes == nil ? 2 : 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIndexes?.count ?? (section == 0 && noItemTitle != nil ? 1 : items.count)
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let isSelected: Bool
        
        
        if let itemIndex = indexForItem(at: indexPath) {
            let item = items[itemIndex]
            cell.textLabel?.text       = item.title
            cell.detailTextLabel?.text = item.subtitle
            isSelected = selectedIndexes.contains(itemIndex)
        } else {
            cell.textLabel?.text       = noItemTitle
            cell.detailTextLabel?.text = nil
            isSelected = selectedIndexes.isEmpty
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
        
        if let itemIndex = indexForItem(at: indexPath) {
            isSelected = selectedIndexes.contains(itemIndex)
        } else {
            isSelected = selectedIndexes.isEmpty
        }
        
        cell.textLabel?.alpha = isSelected ? 1.0 : 0.5
    }
    
    @objc(tableView:didSelectRowAtIndexPath:)
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
        
        let noSectionShowing = noItemTitle != nil && filteredIndexes == nil
        
        if let itemIndex = indexForItem(at: indexPath) {
            if allowsMultipleSelection {
                let isSelected = selectedIndexes.remove(itemIndex) == nil
                if isSelected {
                    selectedIndexes.insert(itemIndex)
                }
                updateCurrentCell(checked: isSelected)
                
                if (selectedIndexes.isEmpty || (isSelected && selectedIndexes.count == 1)) && noSectionShowing {
                    reloadIndexPaths.append(IndexPath(row: 0, section: 0))
                }
            } else {
                if let oldIndexPath = self.indexPathForItem(at: selectedIndexes.first), oldIndexPath != indexPath {
                    reloadIndexPaths.append(oldIndexPath)
                }
                selectedIndexes = IndexSet(integer: itemIndex)
                
                updateCurrentCell(checked: true)
            }
        } else if noSectionShowing {
            // "No" item selected. Filter not showing.
            
            let selectedItemCount = selectedIndexes.count
            
            if selectedItemCount > 0 {
                let oldSelectedIndexes = selectedIndexes
            
                selectedIndexes.removeAll()
                updateCurrentCell(checked: true)
            
                reloadIndexPaths.reserveCapacity(selectedItemCount)
                
                for index in (0..<items.count) where oldSelectedIndexes.contains(index) {
                    reloadIndexPaths.append(IndexPath(row: index, section: 1))
                }
            }
        }
        
        if reloadIndexPaths.isEmpty == false {
            tableView.reloadRows(at: reloadIndexPaths, with: .none)
        }
        
        manualSelectionUpdate = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectionUpdateHandler?(self, selectedIndexes)
    }

    
    // MARK: - Search bar delegate
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
    }
    
    
    // MARK: - Private methods
    
    private func indexForItem(at indexPath: IndexPath) -> Int? {
        if let filteredItems = self.filteredIndexes {
            if indexPath.section != 0 { return nil }
            return filteredItems[indexPath.row]
        }
        let hasNoItemTitle = noItemTitle != nil
        
        if (hasNoItemTitle && indexPath.section != 1) || (hasNoItemTitle == false && indexPath.section != 0) {
            return nil
        }
        return indexPath.row
    }
    
    private func indexPathForItem(at index: Int?) -> IndexPath? {
        if let filteredIndexes = self.filteredIndexes {
            guard let index = index,
                let row = filteredIndexes.index(of: index) else { return nil }
            
            return IndexPath(row: row, section: 0)
        } else {
            let hasNoItem = noItemTitle != nil
            if let index = index {
                return IndexPath(row: index, section: hasNoItem ? 1 : 0)
            } else if hasNoItem {
                return IndexPath(row: 0, section: 0)
            }
            return nil
        }
    }
    
    private func updateFilter() {
        if let searchText = self.searchTerm, searchText.isEmpty == false {
            let term = searchText.trimmingCharacters(in: .whitespaces)
            var indexes: [Int] = []
            if term.isEmpty == false {
                items.enumerated().forEach { (offset, item) in
                    if item.title?.localizedCaseInsensitiveContains(term) ?? false ||
                       item.subtitle?.localizedCaseInsensitiveContains(term) ?? false ||
                        (item as? CustomSearchPickable)?.contains(term) ?? false {
                        indexes.append(offset)
                    }
                }
            }
            self.filteredIndexes = indexes
        } else {
            self.filteredIndexes = nil
        }
    }
}


private extension Array {
    
}
