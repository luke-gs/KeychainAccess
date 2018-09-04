//
//  PrimaryViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 7/8/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit


class PrimaryViewController: UITableViewController, DrawerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Fully open"
        case 1:
            cell.textLabel?.text = "Partially open"
        case 2:
            cell.textLabel?.text = "Collapse"
        default:
            cell.textLabel?.text = "Primary Cell \(indexPath.row + 1)"
        }


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            drawerViewController?.setPosition(.open, animated: true)
        case 1:
            drawerViewController?.setPosition(.partiallyOpen, animated: true)
        case 2:
            drawerViewController?.setPosition(.collapsed, animated: true)
        default:
            break
        }
    }

    func drawerViewControllerPositionDidChange(_ drawerViewController: DrawerViewController, height: CGFloat) {
        if #available(iOS 11.0, *) {
            tableView.contentInset.bottom = height - drawerViewController.drawerSafeAreaInsets.bottom
        } else {
            tableView.contentInset.bottom = height
        }
    }

}

class SecondaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DrawerDraggableViewControllerDelegate {

    let tableView = UITableView(frame: .zero, style: .plain)
    let searchBar = UISearchBar(frame: .zero)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        searchBar.placeholder = "Search for nothing"
        searchBar.sizeToFit()
        searchBar.autoresizingMask = [.flexibleWidth]

        view.addSubview(searchBar)

        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets.top = searchBar.frame.height
        } else {
            tableView.contentInset.top = searchBar.frame.height
            tableView.scrollIndicatorInsets.top = searchBar.frame.height
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {} else {
            let bottom = drawerViewController?.drawerSafeAreaInsets.bottom ?? 0.0
            tableView.contentInset.bottom = bottom
            tableView.scrollIndicatorInsets.bottom = bottom
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Secondary Cell \(indexPath.row + 1)"
        return cell
    }

}

