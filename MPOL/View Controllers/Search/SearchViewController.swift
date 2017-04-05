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

class SearchViewController: UIViewController {
    
    let recentsViewController = SearchRecentsViewController()
    
    private(set) var resultsViewController: UIViewController?
    
    var isShowingResults: Bool { return resultsViewController != nil }
    
    private(set) var isShowingSearchOptions: Bool = false
    
    lazy var searchOptionsViewController: SearchOptionsViewController = { [unowned self] in
        let optionsController = SearchOptionsViewController()
        self.addChildViewController(optionsController)
        optionsController.didMove(toParentViewController: self)
        return optionsController
    }()
    
    
    // MARK: - Private properties
    
    private var searchDimmingView: UIControl?
    
    private var searchPreferredHeight: CGFloat = 0.0
    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
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
        
        let currentVC = resultsViewController ?? recentsViewController
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
            let viewBounds = view.bounds
            var viewFrame = CGRect(x: 0, y: 0, width: viewBounds.width, height: min(searchPreferredHeight + topLayoutGuide.length, viewBounds.height))
            if isShowingSearchOptions == false {
                viewFrame.origin.y = -viewFrame.height
            }
            
            searchOptionsView.frame = viewFrame
            searchOptionsView.setNeedsLayout()
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
        // TODO
    }
    
    private func setResultsViewController(_ controller: UIViewController?, animated: Bool) {
        if controller == resultsViewController { return }
        
        // These will logically never be the same because of the above check.
        let fromVC = resultsViewController ?? recentsViewController
        let toVC   = controller ?? recentsViewController
        
        resultsViewController = controller
        
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
            toVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            transition(from: fromVC, to: toVC, duration: animated ? 0.2 : 0.0, options: [.transitionCrossDissolve], animations: nil, completion: completionHandler)
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
            title = "New Search"
            leftBarButtonItems  = [UIBarButtonItem(barButtonSystemItem: .cancel,   target: self, action: #selector(cancelSearchTriggered))]
            rightBarButtonItems = [UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(performSearchTriggered))]
        } else if isShowingResults {
            titleView = nil // TODO: Should be the mock search bar
            title = nil
            leftBarButtonItems = nil
            rightBarButtonItems = [] // TODO: Configure based on whether the current results vc's nav item options.
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
}
