//
//  CompactSidebarSourceViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Protocol for CompactSidebarSourceViewController
public protocol CompactSidebarSourceViewControllerDelegate: class {

    func sourceViewControllerWillClose(_ viewController: CompactSidebarSourceViewController)
    func sourceViewController(_ viewController: CompactSidebarSourceViewController, didSelectItemAt index: Int)
    func sourceViewController(_ viewController: CompactSidebarSourceViewController, didRequestToLoadItemAt index: Int)
}

/// Simple table view controller for displaying sources and allowing selection
open class CompactSidebarSourceViewController: UITableViewController {

    // MARK: - Public properties

    /// The delegate for source selections
    public weak var delegate: CompactSidebarSourceViewControllerDelegate?

    /// The source items, which may be updated while the table is shown
    public var items: [SourceItem] {
        didSet {
            if let index = selectedIndex, items.count < index {
                selectedIndex = nil
            }
            tableView.reloadData()
        }
    }

    /// The currently selected source
    public var selectedIndex: Int? {
        didSet {
            tableView.reloadData()
        }
    }

    /// Theme to use for view
    public var theme: Theme {
        return ThemeManager.shared.theme(for: .dark)
    }

    // MARK: - View lifecycle
    
    public init(items: [SourceItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(style: .plain)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Other Data Sources", comment: "")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(CompactSidebarSourceCell.self)
        tableView.separatorColor = theme.color(forKey: .separator)
        tableView.tableFooterView = UIView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Use dark background, regardless of theme
        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
    }

    open override var preferredContentSize: CGSize {
        get {
            let navHeight = navigationController?.navigationBar.frame.height ?? 0
            return CGSize(width: view.frame.width - 80, height: max(tableView.contentSize.height + navHeight, 200))
        }
        set {
            super.preferredContentSize = newValue
        }
    }
}

// MARK: - UITableViewDataSource
extension CompactSidebarSourceViewController {

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: CompactSidebarSourceCell.self, for: indexPath)
        let source = items[indexPath.row]

        cell.sourceTitle.text = source.title
        cell.sourceBarCell.update(for: source)
        cell.sourceBarCell.isSelected = (indexPath.row == selectedIndex)

        // Set colors according to theme
        cell.sourceTitle.textColor = theme.color(forKey: .primaryText)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }

    open override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.backgroundColor = .secondaryGray
    }

    open override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.backgroundColor = .clear
    }
}

// MARK: - UITableViewDelegate
extension CompactSidebarSourceViewController {
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let sourceItem = items[indexPath.row]
        switch sourceItem.state {
        case .notLoaded:
            delegate?.sourceViewController(self, didRequestToLoadItemAt: indexPath.row)
        case .loaded:
            delegate?.sourceViewController(self, didSelectItemAt: indexPath.row)
            selectedIndex = indexPath.row

            self.delegate?.sourceViewControllerWillClose(self)
            dismiss(animated: true, completion:nil)
        default:
            break
        }

    }
}

