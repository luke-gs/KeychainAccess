//
//  CompactSidebarSourceViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 8/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Simple table view controller for displaying sources and allowing selection
class CompactSidebarSourceViewController: UITableViewController {

    // MARK: - Private properties

    fileprivate let reuseIdentifier = "reuseIdentifier"

    /// The source items
    fileprivate var items: [SourceItem]

    /// The currently selected source
    fileprivate var selectedIndex: Int

    // MARK: - View lifecycle
    
    init(items: [SourceItem], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
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
            return CGSize(width: view.frame.width - 40, height: view.frame.height / 2)
        }
        set {
            super.preferredContentSize = newValue
        }
    }

    @objc private func didTapDoneButton(_ item: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CompactSidebarSourceViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = ThemeManager.shared.theme(for: .current)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let source = items[indexPath.row]
        cell.textLabel?.text = source.title
        switch source.state {
        case .loaded(let count, let color):
            cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%d Alert(s)", comment: ""), count ?? 0)
        default:
            cell.detailTextLabel?.text = nil
            break
        }
        cell.textLabel?.textColor = theme.color(forKey: .primaryText)
        cell.detailTextLabel?.textColor = theme.color(forKey: .secondaryText)
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CompactSidebarSourceViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

