//
//  CollectionDemoListViewController.swift
//  MPOLKitDemo
//
//  Created by Rod Brown on 10/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class CollectionDemoListViewController: FormTableViewController {
    
    enum CollectionDemo: Int {
        case noContent
        case headersBasicFormCells
        case mapCollectionView
        
        static let count: Int = 3
        
        var title: String? {
            switch self {
            case .noContent:
                return "Loading & No Content"
            case .headersBasicFormCells:
                return "Headers and Basic Form Cells"
            case .mapCollectionView:
                return "Map Collection View"
            }
        }
        
        func newViewController() -> FormCollectionViewController {
            switch self {
            case .noContent:
                return NoContentCollectionController()
            case .headersBasicFormCells:
                return HeadersBasicFormCellsController()
            case .mapCollectionView:
                return MapCollectionViewController()
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        title = "Collection Demo"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Demo", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tableView = self.tableView!
        
        tableView.rowHeight = 44.0
        tableView.register(UITableViewCell.self)
        tableView.cellLayoutMargins = UIEdgeInsets(top: 16.0, left: 24.0, bottom: 16.0, right: 12.0)
        tableView.separatorColor = Theme.current.colors[.Separator]
    }

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CollectionDemo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = CollectionDemo(rawValue: indexPath.row)?.title
        
        if type(of: cell.selectedBackgroundView) != UIView.self {
            // we want to use a custom background which means we can't use the standard UITableViewCell background on
            // grouped cells which is a subclass. Test it's a standard view, and if not, set a standard one.
            cell.selectedBackgroundView = UIView()
        }
        
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        cell.selectedBackgroundView?.backgroundColor = Theme.current.isDark ? .darkGray : #colorLiteral(red: 0.2971355617, green: 0.6317164898, blue: 1, alpha: 1)
        cell.textLabel?.highlightedTextColor = .white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = CollectionDemo(rawValue: indexPath.row)?.newViewController() else {
            return
        }
        
        let navController = UINavigationController(rootViewController: viewController)
        showDetailViewController(navController, sender: self)
    }
    
}

extension UITableViewCell: DefaultReusable {
}

