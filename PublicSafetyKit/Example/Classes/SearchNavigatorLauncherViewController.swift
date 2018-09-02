//
//  SearchLookupAddressTableViewController.swift
//  MPOLKitDemo
//
//  Created by Herli Halim on 23/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


import PromiseKit

enum Options: Int {
    case personSearch
    case vehicleSearch
    case personDetails
    case vehicleDetails
    case openApp

    // Last please
    case all
}

class SearchNavigatorLauncherViewController: UITableViewController {

    var results: [Any] = []
    var searchController: UISearchController!

    override init(style: UITableViewStyle) {
        super.init(style: style)
        title = "Search Navigator"
    }

    let activityLauncher = SearchActivityLauncher()
    let appLauncher = AppLaunchActivityLauncher()

    // Local
//    let activityLauncher = SearchActivityLauncher(scheme: "mpolkitdemo")
//    let appLauncher = AppLaunchActivityLauncher(scheme: "mpolkitdemo")

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
        return Options.all.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: UITableViewCell.self, for: indexPath)

        let text: String
        switch Options(rawValue: indexPath.row)! {
        case .personSearch:
            text = "Person Search"
        case .vehicleSearch:
            text = "Vehicle Search"
        case .personDetails:
            text = "View Person Details (554ca38e-ab00-4c5c-8e58-1c87ef09b958)"
        case .vehicleDetails:
            text = "View Vehicle Details (c4ad9ed4-e261-40d4-a50c-9160b089542b)"
        case .openApp:
            text = "Launch App Just For Fun"
        case .all:
            text = "DERPY DERP HELP PLZ!"
        }

        cell.textLabel?.text = text
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Options(rawValue: indexPath.row)! {
        case .personSearch:
            try? activityLauncher.launch(.searchEntity(term: Searchable(text: "Kaine, Aimee")), using: navigator)
        case .vehicleSearch:
            try? activityLauncher.launch(.searchEntity(term: Searchable(text: "ABC456")), using: navigator)
        case .personDetails:
            try? activityLauncher.launch(.viewDetails(id: "554ca38e-ab00-4c5c-8e58-1c87ef09b958", entityType: "Person", source: "pscore"), using: navigator)
        case .vehicleDetails:
            try? activityLauncher.launch(.viewDetails(id: "c4ad9ed4-e261-40d4-a50c-9160b089542b", entityType: "Vehicle", source: "pscore"), using: navigator)
        case .openApp:
            try? appLauncher.launch(.open, using: navigator)
        case .all:
            fatalError("Call 000")
        }

    }

}

