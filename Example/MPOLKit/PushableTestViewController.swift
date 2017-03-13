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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 50.0
        tableView.register(TableViewFormDetailCell.self)
        tableView.cellLayoutMargins = UIEdgeInsets(top: 16.0, left: 24.0, bottom: 16.0, right: 12.0)
        tableView.separatorColor = Theme.current.colors[.Separator]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: TableViewFormDetailCell.self, for: indexPath)
        cell.textLabel.text =       "Test Cell \(indexPath.row + 1)"
        cell.detailTextLabel.text = "Test Detail Cell \(indexPath.row + 1)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let testVC = TestCollectionViewController()
        
        let popoverNavController = PopoverNavigationController(rootViewController: testVC)
        popoverNavController.modalPresentationStyle = .formSheet
        present(popoverNavController, animated: true)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

