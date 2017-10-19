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
    
    open override func loadView() {
        super.loadView()
        
        // We're going to put the search bar on the background view. The
        // problem here is that it doesn't count as the content view for the
        // loading manager. So we'll create a new base view to hold the old
        // base view, and then the old base view will become the content view.
        
        let oldBackgroundView = self.view!
        oldBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        searchBar.isHidden = isSearchBarHidden
        searchBar.sizeToFit()
        oldBackgroundView.addSubview(searchBar)
        
        let newBackgroundView = UIView(frame: oldBackgroundView.bounds)
        newBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newBackgroundView.addSubview(oldBackgroundView)
        self.view = newBackgroundView
        
        // We switch to a new set of views for content views etc.
        loadingManager.baseView = newBackgroundView
        loadingManager.contentView = oldBackgroundView
    }
    
    open override func viewWillLayoutSubviews() {
        let topLayoutGuideInset: CGFloat

        if #available(iOS 11.0, *) {
            topLayoutGuideInset = view.safeAreaInsets.top
        } else {
            topLayoutGuideInset = topLayoutGuide.length
        }
        print(topLayoutGuideInset)
        
        var searchBarFrame = searchBar.frame
        searchBarFrame.origin.y = topLayoutGuideInset - (isSearchBarHidden ? searchBarFrame.height : 0.0)

        if #available(iOS 11.0, *) {
            searchBarFrame.origin.y -= additionalSafeAreaInsets.top
        }

        searchBarFrame.size.width = tableView?.frame.width ?? 0.0
        searchBar.frame = searchBarFrame
        
        // Do this adjustment in willLayoutSubviews or we risk a layout loop.
        
        let additionalSafeAreaTopInset = !isSearchBarHidden ? searchBarFrame.height : 0.0
        
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = additionalSafeAreaTopInset
        } else {
            legacy_additionalSafeAreaInsets.top = additionalSafeAreaTopInset
        }

        super.viewWillLayoutSubviews()
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

    // MARK: - Search bar delegate

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    // MARK: - Overrides
    
    open override func apply(_ theme: Theme) {
        super.apply(theme)
        
        searchBar.barStyle = userInterfaceStyle.isDark ? .black : .default
    }
    
}
