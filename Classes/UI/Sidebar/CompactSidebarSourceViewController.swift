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

    // MARK: - Private properties

    fileprivate let reuseIdentifier = "reuseIdentifier"

    // MARK: - View lifecycle
    
    init(items: [SourceItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(style: .plain)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        title = NSLocalizedString("Other Data Sources", comment: "")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))

        tableView.rowHeight = 60
        tableView.register(CompactSidebarSourceCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    open override var preferredContentSize: CGSize {
        get {
            return CGSize(width: view.frame.width - 40, height: max(tableView.contentSize.height, 200))
        }
        set {
            super.preferredContentSize = newValue
        }
    }

    @objc private func didTapDoneButton(_ item: UIBarButtonItem) {
        self.delegate?.sourceViewControllerWillClose(self)
        dismiss(animated: true, completion:nil)
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
        let theme = ThemeManager.shared.theme(for: .current)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let source = items[indexPath.row]
        cell.textLabel?.text = source.title

        switch source.state {
        case .notLoaded: fallthrough
        case .loading: fallthrough
        case .notAvailable:
            // TODO: decide UI for source image/icon/loading
            cell.detailTextLabel?.text = nil
            break
        case .loaded(let count, _):
            cell.textLabel?.textColor = theme.color(forKey: .primaryText)
            cell.detailTextLabel?.textColor = theme.color(forKey: .secondaryText)
            cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%d Alert(s)", comment: ""), count ?? 0)
        }

        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        cell.backgroundColor = UIColor.clear
        return cell
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
        default:
            break
        }

    }
}

