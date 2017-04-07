//
//  SearchViewController.swift
//  MPOLKit
//
//  Created by Valery Shorinopv on 21/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

fileprivate let searchAnimationDuration: TimeInterval = 0.4

class SearchViewController: UIViewController, SearchRecentsViewControllerDelegate, SearchResultsDelegate, SearchNavigationFieldDelegate {
    
    let recentsViewController = SearchRecentsViewController()
    
    private(set) var currentResultsViewController: UIViewController?
    
    var isShowingResults: Bool { return currentResultsViewController != nil }
    
    private(set) var isShowingSearchOptions: Bool = false
    
    private lazy var resultsListViewController: SearchResultsListViewController = { [unowned self] in
        let resultsController = SearchResultsListViewController()
        resultsController.delegate = self
        return resultsController
    }()
    
    private lazy var searchOptionsViewController: SearchOptionsViewController = { [unowned self] in
        let optionsController = SearchOptionsViewController()
        self.addChildViewController(optionsController)
        optionsController.didMove(toParentViewController: self)
        return optionsController
    }()
    
    
    private var isSearchNavigationFieldLoaded = false
    
    private lazy var searchNavigationField: SearchNavigationField = { [unowned self] in
        let searchField = SearchNavigationField()
        searchField.titleLabel.text = "Citizen John"
        searchField.typeLabel.text  = "PERSON"
        searchField.resultCountLabel.text = "27 results found"
        searchField.delegate = self
        
        let theme = Theme.current
        let secondaryText = theme.colors[.SecondaryText]
        
        searchField.titleLabel.textColor = theme.colors[.PrimaryText]
        searchField.resultCountLabel.textColor = secondaryText
        searchField.clearButton.tintColor = secondaryText
        
        return searchField
    }()
    
    
    // MARK: - Private properties
    
    private var searchDimmingView: UIControl?
    
    private var searchPreferredHeight: CGFloat = 0.0
    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        recentsViewController.delegate = self
        addChildViewController(recentsViewController)
        recentsViewController.didMove(toParentViewController: self)
        
        updateNavigationItem(animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("SearchViewController does not support NSCoding.")
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentVC = currentResultsViewController ?? recentsViewController
        let currentVCView = currentVC.view!
        
        let view = self.view!
        currentVCView.frame = view.bounds
        currentVCView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(currentVCView)
        
        if isShowingSearchOptions {
            let dimmingView = UIControl(frame: view.bounds)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dimmingView.addTarget(self, action: #selector(cancelSearchTriggered), for: .touchUpInside)
            dimmingView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2957746479)
            self.searchDimmingView = dimmingView
            
            view.addSubview(dimmingView)
            view.addSubview(searchOptionsViewController.view!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let searchOptionsView = searchOptionsViewController.viewIfLoaded, searchOptionsView.superview == self.view {
            searchOptionsView.setNeedsLayout()
            
            let viewBounds = view.bounds
            var viewFrame = CGRect(x: 0, y: 0, width: viewBounds.width, height: min(searchPreferredHeight + topLayoutGuide.length, viewBounds.height))
            if isShowingSearchOptions == false {
                viewFrame.origin.y = -viewFrame.height
            }
            
            searchOptionsView.frame = viewFrame
            searchOptionsView.layoutIfNeeded()
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        guard let viewController = container as? UIViewController, viewController == searchOptionsViewController else { return }
        
        let preferredContentHeight = viewController.preferredContentSize.height
        if fabs(searchPreferredHeight - preferredContentHeight) < 1E-5 { return }
        
        searchPreferredHeight = preferredContentHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    
    // MARK: - Changing state
    
    func setShowingSearchOptions(_ showingOptions: Bool, animated: Bool) {
        if isShowingSearchOptions == showingOptions { return }
        
        isShowingSearchOptions = showingOptions
        updateNavigationItem(animated: isViewLoaded && animated)
        
        guard let view = self.viewIfLoaded else { return }
        
        let optionsVC = self.searchOptionsViewController
        
        if isShowingSearchOptions {
            let dimmingView: UIControl
            if let currentDimmingView = self.searchDimmingView {
                dimmingView = currentDimmingView
            } else {
                dimmingView = UIControl(frame: .zero)
                dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                dimmingView.addTarget(self, action: #selector(cancelSearchTriggered), for: .touchUpInside)
                dimmingView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2957746479)
                self.searchDimmingView = dimmingView
            }
            
            dimmingView.frame = view.bounds
            view.addSubview(dimmingView)
            
            optionsVC.beginAppearanceTransition(true, animated: animated)
            view.addSubview(searchOptionsViewController.view)
            
            searchPreferredHeight = optionsVC.preferredContentSize.height
            
            if animated {
                dimmingView.alpha = 0.0
                
                // temporarily disable the showing of options to allow the item to sit above the screen prior to layout.
                isShowingSearchOptions = false
                view.setNeedsLayout()
                view.layoutIfNeeded()
                
                // re-enable and animate.
                isShowingSearchOptions = true
                UIView.animate(withDuration: searchAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                               animations: {
                                   view.setNeedsLayout()
                                   view.layoutIfNeeded()
                                   dimmingView.alpha = 1.0
                               },
                               completion: { (finished: Bool) in
                                   optionsVC.endAppearanceTransition()
                               })
            } else {
                dimmingView.alpha = 1.0
                view.setNeedsLayout()
                view.layoutIfNeeded()
                optionsVC.endAppearanceTransition()
            }
        } else {
            let dimmingView = self.searchDimmingView
            optionsVC.beginAppearanceTransition(false, animated: animated)
            
            let completionHandler = { (finished: Bool) in
                optionsVC.viewIfLoaded?.removeFromSuperview()
                optionsVC.endAppearanceTransition()
                
                dimmingView?.alpha = 1.0
                dimmingView?.removeFromSuperview()
            }
            
            if animated {
                let view = self.view!
                view.setNeedsLayout()
                
                UIView.animate(withDuration: searchAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                               animations: {
                                  view.layoutIfNeeded()
                                  dimmingView?.alpha = 0.0
                               },
                               completion : completionHandler)
            } else {
                completionHandler(true)
            }
        }
    }
    
    
    // MARK: - SearchRecentsViewControllerDelegate
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: Any?) {
        didSelectEntity(recentEntity as Any)
    }
    
    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: Any?) {
        setShowingSearchOptions(true, animated: true)
        searchOptionsViewController.beginEditingSearchField()
    }
    
    
    // MARK: - SearchNavigationFieldDelegate
    
    func searchNavigationFieldDidSelect(_ field: SearchNavigationField) {
        setShowingSearchOptions(true, animated: true)
    }
    
    func searchNavigationFieldDidSelectClear(_ field: SearchNavigationField) {
        setCurrentResultsViewController(nil, animated: true)
    }
    
    
    // MARK: - SearchResultsDelegate {
    
    
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: Any?) {
        didSelectEntity(entity as Any)
    }
    
    
    // MARK: - Private methods
    
    @objc private func displaySearchTriggered() {
        // TODO: Reset search details
        setShowingSearchOptions(true, animated: true)
        searchOptionsViewController.beginEditingSearchField()
    }
    
    @objc private func cancelSearchTriggered() {
        setShowingSearchOptions(false, animated: true)
    }
    
    @objc private func performSearchTriggered() {
        setShowingSearchOptions(false, animated: true)
        setCurrentResultsViewController(resultsListViewController, animated: true)
    }
    
    @objc private func addEntityTriggered() {
    }
    
    private func setCurrentResultsViewController(_ controller: UIViewController?, animated: Bool) {
        if controller == currentResultsViewController { return }
        
        // These will logically never be the same because of the above check.
        let fromVC = currentResultsViewController ?? recentsViewController
        let toVC   = controller ?? recentsViewController
        
        currentResultsViewController = controller
        
        updateNavigationItem(animated: true)
        
        if toVC == controller {
            addChildViewController(toVC)
        } else if fromVC != recentsViewController {
            fromVC.willMove(toParentViewController: nil)
        }
        
        let completionHandler = { (finished: Bool) in
            if toVC == controller {
                toVC.didMove(toParentViewController: self)
            } else if fromVC != self.recentsViewController {
                fromVC.removeFromParentViewController()
            }
        }
        
        if isViewLoaded {
            let fromView = fromVC.view!
            let toView = toVC.view!
            let animate = animated && view.window != nil
            
            toView.frame = fromView.frame
            toView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toView.alpha = animate ? 0.0 : 1.0
            
            fromVC.beginAppearanceTransition(false, animated: animated)
            toVC.beginAppearanceTransition(true, animated: animated)
            
            view.insertSubview(toView, aboveSubview: fromView)
            
            let transitionCompletionHandler = { (finished: Bool) in
                fromView.removeFromSuperview()
                fromVC.endAppearanceTransition()
                toVC.endAppearanceTransition()
                completionHandler(finished)
            }
            
            if animate {
                UIView.animate(withDuration: 0.15, animations: { toView.alpha = 1.0 }, completion: transitionCompletionHandler)
            } else {
                transitionCompletionHandler(true)
            }
        } else {
            completionHandler(true)
        }
    }
    
    private func updateNavigationItem(animated: Bool) {
        let titleView: UIView?
        let title: String?
        let leftBarButtonItems: [UIBarButtonItem]?
        let rightBarButtonItems: [UIBarButtonItem]?
        
        if isShowingSearchOptions {
            titleView = nil
            title = NSLocalizedString("New Search", comment: "")
            leftBarButtonItems  = [UIBarButtonItem(barButtonSystemItem: .cancel,   target: self, action: #selector(cancelSearchTriggered))]
            rightBarButtonItems = [UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(performSearchTriggered))]
        } else if isShowingResults {
            if self.navigationItem.titleView != searchNavigationField {
                let screenSize = UIScreen.main.bounds
                let maxDimension = max(screenSize.width, screenSize.height)
                searchNavigationField.frame.size.width = maxDimension
            }
            
            titleView = searchNavigationField
            title = nil
            leftBarButtonItems = currentResultsViewController?.navigationItem.leftBarButtonItems
            
            var rightItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEntityTriggered))]
            if let childVCItems = currentResultsViewController?.navigationItem.rightBarButtonItems {
               rightItems += childVCItems
            }
            
            rightBarButtonItems = rightItems
        } else {
            titleView = nil
            title = "MPOL" // TODO: Should be from client
            leftBarButtonItems = nil
            rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(displaySearchTriggered))]
        }
        
        let navigationItem = self.navigationItem
        navigationItem.title = title
        navigationItem.titleView = titleView
        navigationItem.setLeftBarButtonItems(leftBarButtonItems,   animated: animated)
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
    }
    
    private func didSelectEntity(_ entity: Any) {
        let entityViewController = EntityDetailsSplitViewController(entity: entity)
        navigationController?.pushViewController(entityViewController, animated: true)
    }
    
}
