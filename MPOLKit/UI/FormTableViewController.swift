//
//  FormTableViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 17/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A generic form table view controller class for MPOL based applications.
/// 
/// Form table view controller applies default cell layout margins to cells, and configures cells
/// according to the generalized layout.
///
/// Subclasses should use the table view controller dequeue methods rather than calling the methods
/// directly on the table view. This allows the form to correctly configure the cell to the defaults
/// as appropriate.
open class FormTableViewController: UITableViewController {

    /// The layout margins for table view cells.
    ///
    /// The default is the default layout margins for table view cells as of iOS 10.
    public var cellLayoutMargins: UIEdgeInsets = UIEdgeInsets(top: 11.0, left: 0.0, bottom: 10.5, right: 0.0) {
        didSet {
            let cellLayoutMargins = self.cellLayoutMargins
            guard cellLayoutMargins != oldValue, isViewLoaded, let tableView = self.tableView else { return }
            
            let preservesInsets = self.cellLayoutMarginsFollowTableMargins
            
            tableView.beginUpdates()
            tableView.visibleCells.forEach { $0.applyLayoutMargins(cellLayoutMargins, preservingTableViewInsets: preservesInsets) }
            tableView.endUpdates()
        }
    }
    
    
    /// A boolean value indicating whether cells should preserve the table view's layout margins, in
    /// addition to the customized layout margins at `FormTableViewController.cellLayoutMargins`.
    ///
    /// The default is `true`.
    public var cellLayoutMarginsFollowTableMargins: Bool = true {
        didSet {
            let preservesInsets = self.cellLayoutMarginsFollowTableMargins
            
            guard preservesInsets != oldValue, isViewLoaded, let tableView = self.tableView else { return }
            
            let cellLayoutMargins = self.cellLayoutMargins
            
            tableView.beginUpdates()
            tableView.visibleCells.forEach { $0.applyLayoutMargins(cellLayoutMargins, preservingTableViewInsets: preservesInsets) }
            tableView.endUpdates()
        }
    }
    
    
    /// Dequeues a registered reusable cell of a certain type from the table view, and applies the appropriate
    /// layout margins for the current table view settings.
    ///
    /// - Parameters:
    ///   - cellClass: The cell class to dequeue.
    ///   - indexPath: The index path to dequeue a cell for.
    /// - Returns: A correctly typed cell, configured with the default controller settings.
    public func dequeueReusableCell<T: UITableViewCell>(of cellClass: T.Type, for indexPath: IndexPath) -> T {
        return tableView.dequeueReusableCell(of: cellClass, for: indexPath, layoutMargins: cellLayoutMargins, preservesTableLayoutMargins: cellLayoutMarginsFollowTableMargins)
    }
    
    
    /// Dequeues a registered reusable cell from the table view, and applies the appropriate layout margins
    /// for the current table view settings.
    ///
    /// - Parameters:
    ///   - cellClass:  The cell class to dequeue.
    ///   - identifier: The cell ID to dequeue.
    /// - Returns: A cell configured with the default controller settings.
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath, layoutMargins: cellLayoutMargins, preservesTableLayoutMargins: cellLayoutMarginsFollowTableMargins)
    }
    
    
    /// Dequeues a reusable cell from the table view, and applies the appropriate layout margins
    /// for the current table view settings.
    ///
    /// - Parameter identifier: The cell ID to dequeue.
    /// - Returns: A cell configured with the default controller settings, or `nil`.
    public func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        return tableView.dequeueReusableCell(withIdenfitier: identifier, layoutMargins: cellLayoutMargins, preservesTableLayoutMargins: cellLayoutMarginsFollowTableMargins)
    }
}
