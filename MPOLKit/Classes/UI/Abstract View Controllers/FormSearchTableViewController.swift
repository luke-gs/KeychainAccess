//
//  FormSearchTableViewController.swift
//  VCom
//
//  Created by Rod Brown on 11/08/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

fileprivate let cellID = "CellID"

open class FormSearchTableViewController: FormTableViewController, UISearchBarDelegate {
    
    // MARK: - Public Properties
    
    open private(set) var searchBar: UISearchBar?
    
    open var isSearchBarHidden: Bool {
        get { return _isSearchBarHidden }
        set { setSearchBarHidden(newValue, animated: false) }
    }
    
    open func setSearchBarHidden(_ hidden: Bool, animated: Bool) {
        if hidden == _isSearchBarHidden { return }
        
        _isSearchBarHidden = hidden
        
        guard let view = self.view, let searchBar = self.searchBar else { return }
        
        if hidden {
            // Disable search.
            searchBar.endEditing(true)
        } else {
            searchBar.isHidden = false
        }
        
        UIView.animate(withDuration: animated && searchBar.window != nil ? 0.3 : 0.0,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
                           if view.window != nil {
                               view.setNeedsLayout()
                               view.layoutIfNeeded()
                               self.updateContentSize()
                           }
                       },
                       completion: { (isFinished: Bool) in
                           if hidden && isFinished {
                               searchBar.isHidden = true
                           }
                       })
    }
    
    
    // MARK: - Private properties
    
    private var _isSearchBarHidden: Bool = false
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.isHidden = isSearchBarHidden
        searchBar.sizeToFit()
        view.addSubview(searchBar)
        
        self.searchBar = searchBar
        
        applyCurrentTheme()
    }
    
    open override func viewDidLayoutSubviews() {
        // We don't call super because this would adjust things incorrectly, which we would need to reset,
        // and viewDidLayoutSubviews on UIViewController is a no-op.
        
        guard let tableView = self.tableView, let searchBar = self.searchBar else { return }
        
        let topLayoutGuideInset = topLayoutGuide.length
        
        var searchBarFrame = searchBar.frame
        searchBarFrame.origin.y   = topLayoutGuideInset - (isSearchBarHidden ? searchBarFrame.height : 0.0)
        searchBarFrame.size.width = tableView.frame.width
        searchBar.frame = searchBarFrame
        
        let insets = UIEdgeInsets(top: searchBarFrame.maxY, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        tableViewInsetManager?.standardContentInset   = insets
        tableViewInsetManager?.standardIndicatorInset = insets
        
        if tableView.isTracking || tableView.isDecelerating { return }
        
        var tableViewContentOffset = tableView.contentOffset
        tableViewContentOffset.y -= (insets.top - tableView.contentInset.top)
        if tableViewContentOffset.y <= 0.0 && tableViewContentOffset.y > insets.top * -1.0 {
            tableViewContentOffset.y = insets.top * -1.0
        }
        
        tableView.contentOffset = tableViewContentOffset
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Workaround:
        // This works around a bug where in some circumstances the navigation controller doesn't layout on
        // appearance (e.g. when the prompt changes during transition) which can cause the search bar to
        // remain offscreen.
        if let navControllerView = navigationController?.view {
            navControllerView.setNeedsLayout()
            
            UIView.animate(withDuration: animated ? 0.3 : 0.0) {
                navControllerView.layoutIfNeeded()
            }
        }
    }
    
    
    // MARK: - Theme updates
    
    open override func applyCurrentTheme() {
        super.applyCurrentTheme()
        
        searchBar?.barStyle = Theme.current.isDark ? .black : .default
    }
    
    
    // MARK: - Overrides
    
    override internal func updateContentSize() {
        super.updateContentSize()
        
        if isSearchBarHidden == false, let searchBar = self.searchBar {
            preferredContentSize.height += searchBar.frame.height
        }
    }
    
}
