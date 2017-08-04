//
//  FormSearchTableViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 14/04/2017.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate let cellID = "CellID"


/// A `FormTableViewController` subclass with an optional search bar.
open class FormSearchTableViewController: FormTableViewController, UISearchBarDelegate {
    
    // MARK: - Public Properties
    
    /// The search bar for the table.
    ///
    /// This view is positioned over the top of the table view, and is
    /// lazy loaded.
    open private(set) lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    
    /// A boolean value indicating whether the search bar is currently hidden.
    ///
    /// The default is `false`. Setting this value directly performs the update
    /// without animation.
    open var isSearchBarHidden: Bool {
        get { return _isSearchBarHidden }
        set { setSearchBarHidden(newValue, animated: false) }
    }
    
    
    /// Shows or hides the search bar, with an optional animation.
    ///
    /// - Parameters:
    ///   - hidden:   A boolean value indicating whether the search bar should be hidden.
    ///   - animated: A boolean value indicating whether the update should be animated.
    open func setSearchBarHidden(_ hidden: Bool, animated: Bool) {
        if hidden == _isSearchBarHidden { return }
        
        _isSearchBarHidden = hidden
        
        guard let view = self.view else { return }
        
        if hidden {
            // Disable search.
            searchBar.endEditing(true)
        } else {
            searchBar.isHidden = false
        }
        
        updateCalculatedContentHeight()
        
        UIView.animate(withDuration: animated && searchBar.window != nil ? 0.3 : 0.0,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
                           if view.window != nil {
                               view.setNeedsLayout()
                               view.layoutIfNeeded()
                           }
                       },
                       completion: { (isFinished: Bool) in
                           if hidden && isFinished {
                               self.searchBar.isHidden = true
                           }
                       })
    }
    
    
    // MARK: - Private properties
    
    private var _isSearchBarHidden: Bool = false
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        searchBar.isHidden = isSearchBarHidden
        searchBar.sizeToFit()
        view.addSubview(searchBar)
        
        super.viewDidLoad()
    }
    
    open override func viewDidLayoutSubviews() {
        // We don't call super because this would adjust things incorrectly, which we would need to reset,
        // and viewDidLayoutSubviews on UIViewController is a no-op.
        
        guard let scrollView = self.tableView, let insetManager = self.tableViewInsetManager else { return }
        
        let topLayoutGuideInset = topLayoutGuide.length
        
        var searchBarFrame = searchBar.frame
        searchBarFrame.origin.y   = topLayoutGuideInset - (isSearchBarHidden ? searchBarFrame.height : 0.0)
        searchBarFrame.size.width = scrollView.frame.width
        searchBar.frame = searchBarFrame
        
        let insets = UIEdgeInsets(top: searchBarFrame.maxY, left: 0.0, bottom: max(bottomLayoutGuide.length, statusTabBarInset), right: 0.0)
        insetManager.standardContentInset   = insets
        insetManager.standardIndicatorInset = insets
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
    
    
    // MARK: - Overrides
    
    open override func apply(_ theme: Theme) {
        super.apply(theme)
        
        searchBar.barStyle = userInterfaceStyle.isDark ? .black : .default
    }
    
    open override func calculatedContentHeight() -> CGFloat {
        return super.calculatedContentHeight() + (isSearchBarHidden == false ? searchBar.frame.height : 0.0)
    }
    
}
