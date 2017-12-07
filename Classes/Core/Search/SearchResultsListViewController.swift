//
//  SearchResultsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 5/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import Unbox

fileprivate let alertCellID = "alertCell"

class SearchResultsListViewController: FormCollectionViewController, SearchResultViewModelDelegate {

    private enum CellIdentifier: String {
        case empty   = "SearchResultsViewControllerEmpty"
        case loading = "SearchResultsViewControllerLoading"
    }
    
    var viewModel: SearchResultViewModelable? {
        didSet {
            viewModel?.style       = wantsThumbnails ? .grid : .list
            viewModel?.delegate    = self

            if isViewLoaded {
                searchFieldButton?.text = viewModel?.title

                if let collectionView = collectionView {
                    viewModel?.registerCells(for: collectionView)
                    collectionView.reloadData()
                }
                
                updateBarItems()
                updateSearchText()
            }
        }
    }
    
    weak var delegate: SearchResultsDelegate?

    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue { return }

            listStateItem.image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)

            viewModel?.style = wantsThumbnails ? .grid : .list

            if traitCollection.horizontalSizeClass != .compact {
                collectionView?.reloadData()
            }
        }
    }

    private let listStateItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .list), style: .plain, target: nil, action: nil)

    private var searchFieldButton: SearchFieldButton?

    override init() {
        super.init()

        title = NSLocalizedString("Search Results", comment: "Search Results - Navigation Bar Title")

        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.5, left: 8.0, bottom: 14.5, right: 8.0)
        formLayout.distribution = .none

        listStateItem.target = self
        listStateItem.action = #selector(toggleThumbnails)
        listStateItem.imageInsets = .zero

        navigationItem.leftBarButtonItem = UIBarButtonItem.backBarButtonItem(target: self, action: #selector(backButtonItemDidSelect))
        navigationItem.rightBarButtonItems = [listStateItem]
    }


    // MARK: - View lifecycle

    override func viewDidLoad() {
        let searchFieldButton = SearchFieldButton(frame: .zero)
        searchFieldButton.text = viewModel?.title
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.titleLabel?.font = .systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        view.addSubview(searchFieldButton)
        self.searchFieldButton = searchFieldButton

        super.viewDidLoad()

        guard let view = self.view, let collectionView = self.collectionView else { return }

        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(SearchResultErrorCell.self, forCellWithReuseIdentifier: CellIdentifier.empty.rawValue)
        collectionView.register(SearchResultLoadingCell.self, forCellWithReuseIdentifier: CellIdentifier.loading.rawValue)
        
        viewModel?.registerCells(for: collectionView)

        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Due to use of additional safe area insets, we cannot position the top of the
            // searchFieldButton within the safe area in iOS 11, it needs to go above
            constraintAboveSafeAreaOrBelowTopLayout(searchFieldButton)
        ])

        updateBarItems()
        updateSearchText()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        } else {
            legacy_additionalSafeAreaInsets.top = searchFieldButton?.frame.height ?? 0.0
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            if wantsThumbnails {
                collectionView?.reloadData()
            }
        }
        navigationItem.rightBarButtonItems = isCompact ? nil : [listStateItem]
    }

    override func apply(_ theme: Theme) {
        super.apply(theme)
        
        guard let searchField = searchFieldButton else { return }
        
        searchField.backgroundColor = theme.color(forKey: .searchFieldBackground)
        searchField.fieldColor = theme.color(forKey: .searchField)
        searchField.textColor  = primaryTextColor
        searchField.placeholderTextColor = placeholderTextColor
    }
    

    // MARK: - UICollectionViewDataSource methods

    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.results.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let result = viewModel?.results[section] {
            if result.isExpanded == false {
                return 0
            }
            
            switch result.state {
            case .finished where result.error != nil || result.entities.count  == 0:
                return 1
            case .finished:
                return result.entities.count
            case .searching:
                return 1
            default:
                break
            }
            
            return 0
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            
            let sectionResult = viewModel!.results[indexPath.section]
            
            header.text = sectionResult.title
            
            header.showsExpandArrow = true
            header.isExpanded = sectionResult.isExpanded
            
            header.tapHandler = { [weak self] headerView, indexPath in
                guard let `self` = self else { return }
                
                let shouldBeExpanded = headerView.isExpanded == false
                
                self.viewModel!.results[indexPath.section].isExpanded = shouldBeExpanded
                self.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
            }
            
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result = viewModel!.results[indexPath.section]
        switch result.state {
        case .finished where result.error != nil || result.entities.count == 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.empty.rawValue, for: indexPath) as! SearchResultErrorCell
            let message = result.error != nil ? result.error!.localizedDescription : "No records matching your search description have been returned"
            let hasError = result.error != nil

            cell.titleLabel.text = message.isEmpty == false ? message : NSLocalizedString("Unknown error has occurred.", comment: "[Search result screen] - Unknown error message when error doesn't contain localized description")
            cell.actionButton.setTitle(hasError ? "Try Again" : "New Search", for: .normal)
            cell.actionButtonHandler = { [weak self] (cell) in
                guard let `self` = self else {  return }
                if hasError {
                    self.viewModel!.retry(section: indexPath.section)
                } else {
                    self.delegate?.searchResultsControllerDidRequestToEdit(self)
                }
            }
            cell.readMoreButtonHandler = { [weak self] (cell) in
                guard let `self` = self else {  return }
                let messageVC = SearchResultMessageViewController(message: cell.titleLabel.text!)
                let navController = PopoverNavigationController(rootViewController: messageVC)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true, completion: nil)
            }

            cell.apply(theme: ThemeManager.shared.theme(for: userInterfaceStyle))
            return cell
        case .searching:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.loading.rawValue, for: indexPath) as! SearchResultLoadingCell
            cell.titleLabel.text = NSLocalizedString("Retrieving results", comment: "[Search result screen] - Retrieving results")
            cell.activityIndicator.play()
            cell.apply(theme: ThemeManager.shared.theme(for: userInterfaceStyle))
            return cell
        default:
            return viewModel!.collectionView(collectionView, cellForItemAt: indexPath, for: traitCollection)
        }
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let result = viewModel!.results[indexPath.section]
        switch result.state {
        case .finished where result.error != nil,
             .finished where result.entities.count == 0,
             .searching:
            return false
        default:
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        // Note: If this ever crashes, Bryan and Luke get to slap James.
        let entity = viewModel!.results[indexPath.section].entities[indexPath.item]
        delegate?.searchResultsController(self, didSelectEntity: entity)
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
        inset.top    = 4.0
        inset.bottom = 0
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let result = viewModel!.results[indexPath.section]
        switch result.state {
        case .finished where result.error != nil,
             .finished where result.entities.count == 0,
             .searching:
            return collectionView.bounds.width
        default:
            break
        }
        
        return viewModel!.collectionView(collectionView, minimumContentWidthForItemAt: indexPath, for: traitCollection)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let result = viewModel!.results[indexPath.section]
        switch result.state {
        case .finished where result.error != nil,
             .finished where result.entities.count == 0,
             .searching:
            return SearchResultErrorCell.contentHeight
        default:
            break
        }
        
        return viewModel!.collectionView(collectionView, minimumContentHeightForItemAt: indexPath, givenContentWidth: itemWidth, for: traitCollection)
    }

    // MARK: - SearchResultRendererDelegate
    
    func searchResultViewModelDidUpdateResults(_ viewModel: SearchResultViewModelable) {
        //        searchField.resultCountLabel.text = viewModel.status

        updateBarItems()
        updateSearchText()
        collectionView?.reloadData()
    }


    // MARK: - Private methods

    @objc private func searchFieldButtonDidSelect() {
        delegate?.searchResultsControllerDidRequestToEdit(self)
    }

    @objc private func backButtonItemDidSelect() {
        delegate?.searchResultsControllerDidCancel(self)
    }

    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }

    private func updateSearchText() {
        let label = RoundedRectLabel(frame: CGRect(x: 10, y: 10, width: 120, height: 16))
        label.backgroundColor = .clear
        label.borderColor = viewModel?.status?.colour
        label.textColor = viewModel?.status?.colour
        label.text = viewModel?.status?.searchText
        label.cornerRadius = 2.0
        label.sizeToFit()

        searchFieldButton?.accessoryView = label
    }
    
    private func updateBarItems() {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        if var buttons = viewModel?.additionalBarButtonItems {
            if !isCompact {
                buttons.insert(listStateItem, at: 0)
            }
            navigationItem.rightBarButtonItems = buttons
        } else if !isCompact {
            navigationItem.rightBarButtonItems = [listStateItem]
        }
    }
}

/// A delegate to notify that an entity was selected
public protocol EntityDetailsDelegate: class {

    /// Notify the delegate that an entity was selected
    ///
    /// - Parameters:
    ///   - controller: the controller that the entity was selected on
    ///   - entity: the entity that was selected
    func controller(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)

    func controller(_ controller: UIViewController, searchFor searchable: Searchable)
}

protocol SearchResultsDelegate: class {
    func searchResultsControllerDidRequestToEdit(_ controller: UIViewController)
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)
    func searchResultsControllerDidCancel(_ controller: UIViewController)
}


