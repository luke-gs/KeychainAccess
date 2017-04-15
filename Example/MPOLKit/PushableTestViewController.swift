//
//  PushableTestViewController.swift
//  MPOLKit-Example
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class PushableTestViewController: UITableViewController {
    
    enum TestDisplayItem: Int, DisplayItem {
        case item1
        case item2
        case item3
        
        var title: String? {
            switch self {
            case .item1: return "Item 1"
            case .item2: return "Item 2"
            case .item3: return "Item 3"
            }
        }
        
        var subtitle: String? {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 50.0
        tableView.register(TableViewFormSubtitleCell.self)
        tableView.cellLayoutMargins = UIEdgeInsets(top: 16.0, left: 24.0, bottom: 16.0, right: 12.0)
        tableView.separatorColor = Theme.current.colors[.Separator]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: TableViewFormSubtitleCell.self, for: indexPath)
        cell.textLabel.text =       "Test Cell \(indexPath.row + 1)"
        cell.detailTextLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        cell.detailTextLabel.numberOfLines = 2
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let displayItemVC = DisplayItemPickerViewController(style: .grouped, items: [TestDisplayItem.item1, TestDisplayItem.item2, TestDisplayItem.item3])
        displayItemVC.noItemTitle = "Any"
        displayItemVC.allowsMultipleSelection = true
        
        let popoverNavigationController = PopoverNavigationController(rootViewController: displayItemVC)
        popoverNavigationController.modalPresentationStyle = .popover
        if let popoverController = popoverNavigationController.popoverPresentationController {
            popoverController.sourceRect = tableView.rectForRow(at: indexPath)
            popoverController.sourceView = tableView
        }
        
        present(popoverNavigationController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

