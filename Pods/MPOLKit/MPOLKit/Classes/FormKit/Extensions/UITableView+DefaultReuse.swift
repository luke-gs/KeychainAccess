//
//  UITableView+DefaultReuse.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 5/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate var cellLayoutMarginsKey = 1
fileprivate let defaultCellLayoutMargins = UIEdgeInsets(top: 11.0, left: 10.0, bottom: 10.5, right: 10.0)

extension UITableView {
    
    /// The layout margins for the cells.
    ///
    /// Table view cells will by default also preserve their superview's layout guides.
    /// To disable this, set the cell's `preservesSuperviewLayoutSubviews` to false.
    /// 
    /// The default for this property is the standard UITableViewCell settings. This property
    /// is `nil`-resettable, and will always return a non-null value.
    public var cellLayoutMargins: UIEdgeInsets! {
        get {
            return (objc_getAssociatedObject(self, &cellLayoutMarginsKey) as? NSValue)?.uiEdgeInsetsValue ?? defaultCellLayoutMargins
        }
        set {
            let value: NSValue?
            if let newValue = newValue {
                value = NSValue(uiEdgeInsets: newValue)
            } else {
                value = nil
            }
            objc_setAssociatedObject(self, &cellLayoutMarginsKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Get the index paths of all cells. Don't rely on visibleCells because there may be
            // first responder cells offscreen not visible, or there may be prefetched cells. We also want
            // to avoid loading the table view unnecessarily.
            var loadedCellIndexPaths = [IndexPath]()
            for view in subviews  {
                if let cell = view as? UITableViewCell, let indexPath = indexPath(for: cell) {
                    loadedCellIndexPaths.append(indexPath)
                }
            }
            
            // Reload all loaded rows.
            // It'd be better to apply the layout attributes directly and rely on -beginUpdates and -endUpdates
            // to resize, but we can't because some cells may not have had cellLayoutMargins applied.
            if loadedCellIndexPaths.isEmpty == false {
                reloadRows(at: loadedCellIndexPaths, with: .fade)
            }
        }
    }
    
    
    /// Registers a cell with the default reuse identifier for the class.
    ///
    /// - Important: This method uses the cell's default reuse identifier. Please see
    ///              the limitations with that API to ensure you avoid creating ID conflicts.
    /// - Parameter cellClass: The cell class to register.
    public final func register<T: UITableViewCell>(_ cellClass: T.Type) where T: DefaultReusable {
        register(cellClass, forCellReuseIdentifier: cellClass.defaultReuseIdentifier)
    }
    
    
    /// Dequeues a DefaultResuable cell registered with the default reuse identifier for the class.
    ///
    /// - Note: Unlike the other methods for cell reuse below, this method applies cell layout margins
    ///         by default. The other methods "default" implementation falls back to the
    ///         `UITableView` standard dequeue methods which do not apply any layout margin adjustment.
    ///
    /// - Parameters:
    ///   - cellClass: The cell class to dequeue.
    ///   - indexPath: The index path to dequeue a cell for.
    ///   - applyingLayoutMargins:  A boolean value indicating whether the cell layout margins should be applied. The default is `true`.
    /// - Returns: A correctly typed cell dequeued for use in the table view.
    public final func dequeueReusableCell<T: UITableViewCell>(of cellClass: T.Type, for indexPath: IndexPath, applyingLayoutMargins: Bool = true) -> T where T: DefaultReusable {
        return dequeueReusableCell(withIdentifier: cellClass.defaultReuseIdentifier, for: indexPath, applyingLayoutMargins: applyingLayoutMargins) as! T
    }
    
    
    /// Dequeues a cell registered with the specified ID.
    ///
    /// - Parameters:
    ///   - identifier: The identifier to dequeue the cell for.
    ///   - indexPath:  The index path to dequeue the cell for.
    ///   - applyingLayoutMargins: A boolean value indicating whether the cell layout margins should be applied.
    /// - Returns: A cell dequeued for use in the table view.
    public final func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath, applyingLayoutMargins: Bool) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if applyingLayoutMargins { cell.apply(cellLayoutMargins) }
        return cell
    }
    
    
    /// Dequeues a reusable cell registered with the specified ID, if it exists.
    ///
    /// - Parameters:
    ///   - identifier: The identifier to dequeue the cell for.
    ///   - applyingLayoutMargins: A boolean value indicating whether the cell layout margins should be applied.
    /// - Returns: A cell dequeued for use in the table view, or `nil`.
    public final func dequeueReusableCell(withIdenfitier identifier: String, applyingLayoutMargins: Bool) -> UITableViewCell? {
        let cell = dequeueReusableCell(withIdentifier: identifier)
        if applyingLayoutMargins { cell?.apply(cellLayoutMargins) }
        return cell
    }
}
