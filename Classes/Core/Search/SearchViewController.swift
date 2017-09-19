//
//  SearchViewController.swift
//  MPOLKit
//
//  Created by Valery Shorinopv on 21/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate let searchAnimationDuration: TimeInterval = 0.4

fileprivate var kvoContext = 1

fileprivate let navigationItemKeyPaths: [String] = [
    #keyPath(UINavigationItem.leftBarButtonItems),
    #keyPath(UINavigationItem.leftBarButtonItem),
    #keyPath(UINavigationItem.rightBarButtonItems),
    #keyPath(UINavigationItem.rightBarButtonItem),
    #keyPath(UINavigationItem.title),
    #keyPath(UINavigationItem.titleView),
    #keyPath(UINavigationItem.prompt)
]

public class SearchViewController: UIViewController, SearchRecentsViewControllerDelegate, SearchResultsDelegate, SearchOptionsViewControllerDelegate, EntityDetailsDelegate, LocationMapSearchDelegate {

    private var recentsViewController: SearchRecentsViewController
    public var viewModel: SearchViewModel

    @objc dynamic private(set) var currentResultsViewController: UIViewController? {
        didSet {
            if currentResultsViewController != oldValue {
                navigationItemKeyPaths.forEach {
                    oldValue?.navigationItem.removeObserver(self, forKeyPath: $0, context: &kvoContext)
                    currentResultsViewController?.navigationItem.addObserver(self, forKeyPath: $0, context: &kvoContext)
                }
            }
            
            if isShowingSearchOptions == false {
                isHidingNavigationBarShadow = isShowingResults == false && recentsViewController.isShowingNavBarExtension
            }
        }
    }
    
    var isShowingResults: Bool {
        return currentResultsViewController != nil
    }
    
    private(set) var isShowingSearchOptions: Bool = false {
        didSet {
            if isShowingSearchOptions == oldValue { return }
            
            isHidingNavigationBarShadow = isShowingSearchOptions || (isShowingResults == false && recentsViewController.isShowingNavBarExtension)
        }
    }
    
    // MARK: - Private methods

    private lazy var mapResultsViewController: SearchResultMapViewController = { [unowned self] in
        let resultsController = SearchResultMapViewController()
        resultsController.delegate = self
        resultsController.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarButtonItem(target: self, action: #selector(backButtonItemDidSelect))
        return resultsController
    }()

    private lazy var resultsListViewController: SearchResultsListViewController = { [unowned self] in
        let resultsController = SearchResultsListViewController()
        resultsController.delegate = self
        return resultsController
    }()
    
    private lazy var searchOptionsViewController: SearchOptionsViewController = { [unowned self] in
        let optionsController = SearchOptionsViewController(dataSources: self.viewModel.dataSources)
        optionsController.delegate = self
        self.addChildViewController(optionsController)
        optionsController.didMove(toParentViewController: self)
        return optionsController
    }()

    
    // MARK: - Private properties

    private var searchDimmingView: UIControl?
    
    private var searchPreferredHeight: CGFloat = 0.0
    
    private var isHidingNavigationBarShadow = false {
        didSet {
            if isHidingNavigationBarShadow == oldValue || navigationController?.topViewController != self { return }
            
            navigationController?.navigationBar.shadowImage = isHidingNavigationBarShadow ? UIImage() : ThemeManager.shared.theme(for: .current).image(forKey: .navigationBarShadow)
        }
    }
    
    
    // MARK: - Initializers
    
    public init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        self.recentsViewController = SearchRecentsViewController(viewModel: viewModel.recentViewModel)

        super.init(nibName: nil, bundle: nil)

        self.viewModel.entityDelegate = self

        automaticallyAdjustsScrollViewInsets = false
        
        tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        recentsViewController.delegate = self
        addChildViewController(recentsViewController)
        recentsViewController.didMove(toParentViewController: self)
        
        let recentsNavItem = recentsViewController.navigationItem
        let optionsNavItem = searchOptionsViewController.navigationItem
        navigationItemKeyPaths.forEach {
            recentsNavItem.addObserver(self, forKeyPath: $0, context: &kvoContext)
            optionsNavItem.addObserver(self, forKeyPath: $0, context: &kvoContext)
        }
        
        recentsViewController.addObserver(self, forKeyPath: #keyPath(SearchRecentsViewController.isShowingNavBarExtension), context: &kvoContext)
        
        updateNavigationItem(animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("SearchViewController does not support NSCoding.")
    }
    
    deinit {
        recentsViewController.removeObserver(self, forKeyPath: #keyPath(SearchRecentsViewController.isShowingNavBarExtension), context: &kvoContext)
        
        let recentsNavItem = recentsViewController.navigationItem
        let resultsNavItem = currentResultsViewController?.navigationItem
        let optionsNavItem = searchOptionsViewController.navigationItem
        navigationItemKeyPaths.forEach {
            recentsNavItem.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            resultsNavItem?.removeObserver(self, forKeyPath: $0, context: &kvoContext)
            optionsNavItem.removeObserver(self, forKeyPath: $0, context: &kvoContext)
        }
    }
    
    
    // MARK: - View lifecycle
    
    override public func viewDidLoad() {
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
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isHidingNavigationBarShadow {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = ThemeManager.shared.theme(for: .current).image(forKey: .navigationBarShadow)
    }
    
    override public func viewDidLayoutSubviews() {
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
    
    override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        guard let viewController = container as? UIViewController, viewController == searchOptionsViewController else { return }
        
        let preferredContentHeight = viewController.preferredContentSize.height
        if fabs(searchPreferredHeight - preferredContentHeight) < 1E-5 { return }
        
        searchPreferredHeight = preferredContentHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    public func set(leftBarButtonItem button: UIBarButtonItem) {
        self.recentsViewController.navigationItem.leftBarButtonItem = button
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
                UIView.animate(withDuration: searchAnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
                    dimmingView.alpha = 1.0
                }, completion: { _ in
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
            
            let completionHandler = { [weak self] (finished: Bool) in
                if self?.isShowingSearchOptions ?? true { return }
                
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

    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentEntity recentEntity: MPOLKitEntity) {
        didSelectEntity(recentEntity)
    }

    func searchRecentsController(_ controller: SearchRecentsViewController, didSelectRecentSearch recentSearch: Searchable) {
        searchOptionsViewController.setCurrent(searchable: recentSearch)
        setShowingSearchOptions(true, animated: true)
    }

    func searchRecentsControllerDidSelectNewSearch(_ controller: SearchRecentsViewController) {
        displaySearchTriggered()
    }

    
    // MARK: - SearchOptionsViewControllerDelegate

    func searchOptionsController(_ controller: SearchOptionsViewController, didFinishWith searchable: Searchable?, andResultViewModel viewModel: SearchResultModelable?) {
        // Present search results view if there is a view model
        if let viewModel = viewModel as? SearchResultViewModelable {
            resultsListViewController.viewModel = viewModel
            
            setShowingSearchOptions(false, animated: true)
            setCurrentResultsViewController(resultsListViewController, animated: true)
        } else if let viewModel = viewModel as? MapResultViewModelable {
            // ToDo: - Use the view model
            print(viewModel)
            mapResultsViewController.viewModel = viewModel
            // End ToDo:
            setShowingSearchOptions(false, animated: true)
            setCurrentResultsViewController(mapResultsViewController, animated: true)
        }




        if let searchable = searchable {
            var viewModel = self.viewModel.recentViewModel

            // Add to recently searched list
            let existingIndex = viewModel.recentlySearched.index(of: searchable)
            if let existingIndex = existingIndex {
                //existing -> move to top
                viewModel.recentlySearched.insert(viewModel.recentlySearched.remove(at: existingIndex), at: 0)
            } else {
                //create new at top
                viewModel.recentlySearched.insert(searchable, at: 0)
            }

            if viewModel.recentlySearched.isEmpty || searchable != viewModel.recentlySearched.first {
                viewModel.recentlySearched.insert(searchable, at: 0)
            }
        }
    }

    func searchOptionsControllerDidCancel(_ controller: SearchOptionsViewController) {
        cancelSearchTriggered()
    }


    // MARK: Entity Delegate
    public func controller(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity) {
        didSelectEntity(entity)
    }

    // MARK: - SearchResultsDelegate

    func searchResultsControllerDidRequestToEdit(_ controller: UIViewController) {
        setShowingSearchOptions(true, animated: true)
    }

    func searchResultsControllerDidCancel(_ controller: UIViewController) {
        setCurrentResultsViewController(nil, animated: true)
    }

    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity) {
        didSelectEntity(entity)
    }
    
    // MARK: LocationMapSearchDelegate
    
    func locationMapViewController(_ controller: UIViewController, didRequestToEdit search: Searchable?) {
        setCurrentResultsViewController(nil, animated: true)
        searchOptionsViewController.setCurrent(searchable: search)
        setShowingSearchOptions(true, animated: true)
    }
    
    // MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            guard let object = object as? NSObject else { return } // KVO on something that wasn't an NSObject? Weird.
            
            if object == recentsViewController {
                if isShowingSearchOptions == false && isShowingResults == false {
                    isHidingNavigationBarShadow = recentsViewController.isShowingNavBarExtension
                }
            } else if object is UINavigationItem {
                updateNavigationItem(animated: true)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private methods

    @objc private func backButtonItemDidSelect() {
        setCurrentResultsViewController(nil, animated: true)
    }

    @objc private func displaySearchTriggered() {
        func showSearchDetails() {
            // Reset every data source prior to presenting.
            searchOptionsViewController.resetSearch()
            
            setShowingSearchOptions(true, animated: true)
        }

        if presentedViewController != nil {
            dismiss(animated: true, completion: showSearchDetails)
        } else {
            showSearchDetails()
        }
    }
    
    @objc private func cancelSearchTriggered() {
        setShowingSearchOptions(false, animated: true)
    }
    
    @objc private func addEntityTriggered() {
    }
    
    private func setCurrentResultsViewController(_ controller: UIViewController?, animated: Bool, completion: ((Bool) -> Void)? = nil) {
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
            completion?(finished)
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
                UIView.animate(withDuration: 0.2, animations: { toView.alpha = 1.0 }, completion: transitionCompletionHandler)
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
        let prompt: String?
        let leftBarButtonItems: [UIBarButtonItem]?
        let rightBarButtonItems: [UIBarButtonItem]?
        
        if isShowingSearchOptions {
            let navigationItem = searchOptionsViewController.navigationItem
            title = navigationItem.title
            titleView = navigationItem.titleView
            leftBarButtonItems = navigationItem.leftBarButtonItems
            rightBarButtonItems = navigationItem.rightBarButtonItems
            prompt = navigationItem.prompt
        } else if isShowingResults {
            let navigationItem = currentResultsViewController?.navigationItem
            titleView = navigationItem?.titleView
            title = navigationItem?.title
            prompt = navigationItem?.prompt
            leftBarButtonItems = navigationItem?.leftBarButtonItems
            rightBarButtonItems = navigationItem?.rightBarButtonItems
        } else {
            let navigationItem = recentsViewController.navigationItem
            titleView = navigationItem.titleView
            title = navigationItem.title
            prompt = navigationItem.prompt
            leftBarButtonItems = navigationItem.leftBarButtonItems
            
            rightBarButtonItems = [UIBarButtonItem(title: NSLocalizedString("New Search", comment: "Search - New Search Button"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(displaySearchTriggered))] + (navigationItem.rightBarButtonItems ?? [])
        }
        
        let navigationItem = self.navigationItem
        navigationItem.title = title
        navigationItem.titleView = titleView
        navigationItem.prompt = prompt
        navigationItem.setLeftBarButtonItems(leftBarButtonItems,   animated: animated)
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
    }

    private func didSelectEntity(_ entity: MPOLKitEntity) {
        let presentable = viewModel.presentable(for: entity)
        present(presentable)

        var recentViewModel = viewModel.recentViewModel

        var recents = recentViewModel.recentlyViewed
        guard recents.first != entity else { return }

        for (index, oldEntity) in recents.enumerated() {
            if oldEntity == entity {
                recents.remove(at: index)
                break
            }
        }
        recents.insert(entity, at: 0)

        recentViewModel.recentlyViewed = recents
    }

}
