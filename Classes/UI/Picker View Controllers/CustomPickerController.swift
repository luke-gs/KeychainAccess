//
//  CustomPickerController.swift
//  MPOLKit
//
//  Created by QHMW64 on 12/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

fileprivate let cellID = "CellID"

public protocol CustomSearchPickerDatasource {
    var objects: [Pickable] { get set }
    var selectedObjects: [Pickable]? { get set }
    var title: String? { get }
    var allowsMultipleSelection: Bool { get }
    var dismissOnFinish: Bool { get }

    var header: CustomisableSearchHeaderView? { get }

    func allowsSelection(of object: Pickable) -> Bool
    func updateHeader(for objects: [Pickable])

    func isValidSelection(for objects: [Pickable]) -> Bool
    func requiredIndexes() -> [Int]
    func selectedIndexes() -> [Int]
}

public extension CustomSearchPickerDatasource {
    public func requiredIndexes() -> [Int] {
        return objects.enumerated().filter { !allowsSelection(of: $0.element) }.map { $0.offset}
    }

    public func isValidSelection(for objects: [Pickable]) -> Bool {
        return objects.count > 0
    }

    public func selectedIndexes() -> [Int] {
        return objects.enumerated().filter { (index, object) -> Bool in
            return selectedObjects?.contains(where: { $0.isEqual(to: object) }) == true
        }.map { $0.offset }
    }
}

public class CustomPickerController: FormTableViewController {

    // MARK: - Public properties

    public var objects: [Pickable] {
        return datasource.objects
    }

    public let datasource: CustomSearchPickerDatasource

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
                if allowsQuickSelection {
                    indexPathsToReload.append(IndexPath(row: 0, section: 0))
                }

                let section = allowsQuickSelection ? 1 : 0

                for row in (0..<datasource.objects.count) where indexesChangingSelection.contains(row) {
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
    open var selectionUpdateHandler: ((CustomPickerController, IndexSet) -> Void)?

    /// An update handler to fire when the view controller dismisses or is popped from
    /// a `UINavigationController` stack.
    ///
    /// The parameters are the table view controller, and the indexes selected.
    open var finishUpdateHandler: ((CustomPickerController, IndexSet) -> Void)?

    /// Indicates if top cell displays "Select/Deselect" button for quicker selection
    open var allowsQuickSelection: Bool  = false {
        didSet {
            guard allowsQuickSelection != oldValue, let tableView = self.tableView else { return }
            tableView.reloadData()
        }
    }


    /// The current search term.
    ///
    /// This is automatically set to `nil` when the search bar is hidden.
    open var searchTerm: String? {
        didSet {
            if searchTerm == oldValue { return }
            datasource.header?.searchBar.text = searchTerm
            updateFilter()
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

    public init(datasource: CustomSearchPickerDatasource, style: UITableViewStyle = .plain) {
        self.datasource = datasource
        super.init(style: style)

        title = datasource.title
        clearsSelectionOnViewWillAppear = false
        allowsMultipleSelection = datasource.allowsMultipleSelection
        updateFilter()

        datasource.selectedIndexes().forEach { selectedIndexes.insert($0) }
        datasource.header?.searchHandler = {
            self.searchTerm = $0
        }
        let button: UIBarButtonItem
        button = UIBarButtonItem(title: datasource.dismissOnFinish ? "Done": "Next", style: .plain, target: self, action: #selector(doneTapped(sender:)))

        button.isEnabled = datasource.isValidSelection(for: [])
        navigationItem.rightBarButtonItem = button
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    @objc private func doneTapped(sender: UIBarButtonItem) {
        finishUpdateHandler?(self, selectedIndexes)
        if datasource.dismissOnFinish {
            dismiss(animated: true, completion: nil)
        }
    }


    @objc private func cancelTapped(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - View lifecycle

    override public func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.clear

        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.tableFooterView = UIView()

        guard let tableView = tableView else { return }

        var constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor).withPriority(.almostRequired)
        ]

        if let headerView = datasource.header {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(headerView)

            constraints.append(contentsOf: [
                headerView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
                headerView.leadingAnchor.constraint(equalTo: view.safeAreaOrFallbackLeadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.safeAreaOrFallbackTrailingAnchor),
                headerView.heightAnchor.constraint(lessThanOrEqualToConstant: 144),

                tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            ])
        } else {
            constraints.append(tableView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        tableView?.rowHeight = 64.0
        datasource.header?.searchBar.text = searchTerm
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Scroll to the first selected index in the list.

        guard let firstSelectedIndex = selectedIndexes.first else {
            if allowsQuickSelection {
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
            section = allowsQuickSelection ? 1 : 0
        }

        if let moveToRow = firstSelectedRow {
            tableView?.scrollToRow(at: IndexPath(row: moveToRow, section: section), at: .none, animated: false)
        }
    }

    // MARK: - UITableViewDataSource methods

    @objc(numberOfSectionsInTableView:) // Workaround. See: http://stackoverflow.com/questions/39416385/swift-3-objc-optional-protocol-method-not-called-in-subclass
    open func numberOfSections(in tableView: UITableView) -> Int {
        return allowsQuickSelection && filteredIndexes == nil ? 2 : 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIndexes?.count ?? (section == 0 && allowsQuickSelection ? 1 : objects.count)
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)

        let isSelected: Bool


        if let itemIndex = indexForItem(at: indexPath) {
            let item = objects[itemIndex]
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.subtitle
            isSelected = selectedIndexes.contains(itemIndex)
        } else {
            if allowsMultipleSelection {
                if selectedIndexes.count < datasource.objects.count {
                    cell.textLabel?.text = NSLocalizedString("Select All", bundle: .mpolKit, comment: "")
                } else {
                    cell.textLabel?.text = NSLocalizedString("Deselect All", bundle: .mpolKit, comment: "")
                }
            } else {
                cell.textLabel?.text = NSLocalizedString("Deselect All", bundle: .mpolKit, comment: "")
            }
            cell.detailTextLabel?.text = nil
            isSelected = false
            cell.selectionStyle = .none
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

        if let index = indexForItem(at: indexPath) {
            let item = objects[index]
            cell.textLabel?.alpha = !datasource.allowsSelection(of: item) ? 0.25 : 1.0
        } else {
            cell.textLabel?.alpha = 1.0
            cell.textLabel?.textColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint) ?? tintColor
        }
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

        let quickSelectionShowing = allowsQuickSelection && filteredIndexes == nil

        if let itemIndex = indexForItem(at: indexPath) {
            if datasource.allowsSelection(of: objects[itemIndex]) {
                if allowsMultipleSelection {
                    let isSelected = selectedIndexes.remove(itemIndex) == nil
                    if isSelected {
                        selectedIndexes.insert(itemIndex)
                    }
                    updateCurrentCell(checked: isSelected)
                } else {
                    let isSelected = selectedIndexes.remove(itemIndex) == nil
                    if isSelected {
                        reloadIndexPaths.append(contentsOf: selectedIndexes.compactMap({ indexPathForItem(at: $0)} ))
                        selectedIndexes = IndexSet(integer: itemIndex)

                        // If there are any required fields they must be inserted into the set
                        datasource.requiredIndexes().forEach { selectedIndexes.insert($0) }
                    }
                    updateCurrentCell(checked: isSelected)
                }
            }
        } else if quickSelectionShowing {
            // Can be switched from All/None
            let selectedCount = selectedIndexes.count

            if !allowsMultipleSelection || selectedCount == datasource.objects.count {
                // Deselect all
                let oldSelectedIndexes = selectedIndexes

                selectedIndexes.removeAll()

                // Re insert the required rows
                datasource.requiredIndexes().forEach { selectedIndexes.insert($0) }

                reloadIndexPaths.reserveCapacity(selectedCount + 1)

                for index in (0..<datasource.objects.count) where oldSelectedIndexes.contains(index) {
                    reloadIndexPaths.append(IndexPath(row: index, section: 1))
                }
            } else {
                selectedIndexes = IndexSet(integersIn: 0...datasource.objects.count - 1)

                reloadIndexPaths.reserveCapacity(datasource.objects.count + 1)

                for index in (0..<datasource.objects.count) {
                    reloadIndexPaths.append(IndexPath(row: index, section: 1))
                }
            }
        }

        if quickSelectionShowing {
            reloadIndexPaths.append(IndexPath(row: 0, section: 0))
        }

        if reloadIndexPaths.isEmpty == false {
            tableView.reloadRows(at: reloadIndexPaths, with: .none)
        }

        manualSelectionUpdate = false

        tableView.deselectRow(at: indexPath, animated: true)
        selectionUpdateHandler?(self, selectedIndexes)

        let selectedValues = selectedIndexes.map { objects[$0] }
        datasource.updateHeader(for: selectedValues)
        navigationItem.rightBarButtonItem?.isEnabled = datasource.isValidSelection(for: selectedValues)
    }

    // MARK: - Private methods

    private func indexForItem(at indexPath: IndexPath) -> Int? {
        if let filteredItems = self.filteredIndexes {
            if indexPath.section != 0 { return nil }
            return filteredItems[indexPath.row]
        }

        if allowsQuickSelection && indexPath.section == 0 {
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
            if let index = index {
                return IndexPath(row: index, section: allowsQuickSelection ? 1 : 0)
            } else if allowsQuickSelection {
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
                datasource.objects.enumerated().forEach { (offset, item) in
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
