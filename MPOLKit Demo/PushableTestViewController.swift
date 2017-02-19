//
//  PushableTestViewController.swift
//  Test
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class PushableTestViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMargins = UIEdgeInsets(top: 25.0, left: 50.0, bottom: 25.0, right: 50.0)
        tableView.estimatedRowHeight = 50.0
        tableView.register(TableViewFormCell.self)
        tableView.separatorColor = Theme.current.colors[.Separator]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: TableViewFormCell.self, for: indexPath)
        cell.textLabel?.text = "Test Cell \(indexPath.row + 1)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let splitViewController = PushableSplitViewController(viewControllers: [UINavigationController(rootViewController: PushableTestViewController(style: .grouped)), UINavigationController()])
        pushableSplitViewController?.navigationController?.pushViewController(splitViewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

