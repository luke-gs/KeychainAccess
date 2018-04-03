//
//  SearchLookupAddressTableViewController.swift
//  MPOLKitDemo
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

import PromiseKit

class SearchNavigatorLauncherViewController: UITableViewController {

    var results: [Any] = []
    var searchController: UISearchController!

    override init(style: UITableViewStyle) {
        super.init(style: style)
        title = "Search Navigator"
    }

    let activityLauncher = SearchActivityLauncher(scheme: "mpolkitdemo")
    let navigator = UIApplication.shared.magicAppDelegate.navigator
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: UITableViewCell.self, for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = "Launch Entity Search"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Launch View Details"
        } else {
            cell.textLabel?.text = "Launch App Just For Fun"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            try? activityLauncher.launch(.searchEntity(term: Searchable(text: "FamilyName, FirstName MiddleName"), source: "pisscore"), using: navigator)
        }  else if indexPath.row == 1 {
            try? activityLauncher.launch(.viewDetails(id: "1", entityType: "Person", source: "pisscore"), using: navigator)
        }
        else {
            try? activityLauncher.launch(.launchApp, using: navigator)
        }

    }

}

