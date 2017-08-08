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
                if let collectionView = collectionView {
                    viewModel?.registerCells(for: collectionView)
                    
                    collectionView.reloadData()
                }
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

        title = NSLocalizedString("Search Results", comment: "Navigation Bar Title") // Temp

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
        searchFieldButton.translatesAutoresizingMaskIntoConstraints = false
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        view.addSubview(searchFieldButton)
        self.searchFieldButton = searchFieldButton

        super.viewDidLoad()

        guard let view = self.view, let collectionView = self.collectionView else { return }

        if let collectionView = self.collectionView {
            collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
            collectionView.register(SearchResultErrorCell.self, forCellWithReuseIdentifier: CellIdentifier.empty.rawValue)
            collectionView.register(SearchResultLoadingCell.self, forCellWithReuseIdentifier: CellIdentifier.loading.rawValue)
            
            viewModel?.registerCells(for: collectionView)
        }

        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchFieldButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
        ])
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let insets = UIEdgeInsets(top: topLayoutGuide.length + (searchFieldButton?.frame.height ?? 0.0), left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)

        loadingManager.contentInsets = insets
        collectionViewInsetManager?.standardContentInset = insets
        collectionViewInsetManager?.standardIndicatorInset = insets
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            if wantsThumbnails {
                collectionView?.reloadData()
            }
            navigationItem.rightBarButtonItems = isCompact ? nil : [listStateItem]
        }
    }

    override func applyCurrentTheme() {
        super.applyCurrentTheme()

        guard let searchField = searchFieldButton else { return }

        let themeColors = Theme.current.colors

        searchField.backgroundColor = themeColors[.SearchFieldBackground]
        searchField.fieldColor = themeColors[.SearchField]
        searchField.textColor  = primaryTextColor
        searchField.placeholderTextColor = placeholderTextColor
    }


    // MARK: - UICollectionViewDataSource methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.results.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let result = viewModel?.results[section] {
            if result.isExpanded == false {
                return 0
            }
            
            switch result.state {
            case .finished where result.error != nil:
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
            
            header.tapHandler = { [weak self] (headerView, indexPath) in
                guard let `self` = self else { return }
                
                let shouldBeExpanded = headerView.isExpanded == false
                
                self.viewModel!.results[indexPath.section].isExpanded = shouldBeExpanded
                self.collectionView?.reloadData()
            }
            
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result = viewModel!.results[indexPath.section]
        
        switch result.state {
        case .finished where result.error != nil:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.empty.rawValue, for: indexPath) as! SearchResultErrorCell
            let message = result.error!.localizedDescription
            cell.titleLabel.text = message.isEmpty == false ? message : NSLocalizedString("Unknown error has occurred.", comment: "[Search result screen] - Unknown error message when error doesn't contain localized description")
            cell.buttonHandler = { [weak self] (cell) in
                self?.viewModel!.retry(section: indexPath.section)
            }
            cell.apply(theme: Theme.current)
            return cell
        case .searching:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.loading.rawValue, for: indexPath) as! SearchResultLoadingCell
            cell.titleLabel.text = NSLocalizedString("Retrieving results", comment: "[Search result screen] - Retrieving results")
            cell.apply(theme: Theme.current)
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
        case .finished where result.error != nil:
            return false
        case .searching:
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
        case .finished where result.error != nil:
            return collectionView.bounds.width
        case .searching:
            return collectionView.bounds.width
        default:
            break
        }
        
        return viewModel!.collectionView(collectionView, minimumContentWidthForItemAt: indexPath, for: traitCollection)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let result = viewModel!.results[indexPath.section]
        switch result.state {
        case .finished where result.error != nil:
            return 152
        case .searching:
            return 152
        default:
            break
        }
        
        return viewModel!.collectionView(collectionView, minimumContentHeightForItemAt: indexPath, givenContentWidth: itemWidth, for: traitCollection)
    }

    // MARK: - SearchResultRendererDelegate
    
    func searchResultViewModelDidUpdateResults(_ viewModel: SearchResultViewModelable) {
//        searchField.resultCountLabel.text = viewModel.status
        
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
}

protocol SearchResultsDelegate: class {
    func searchResultsControllerDidRequestToEdit(_ controller: UIViewController)
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: MPOLKitEntity)
    func searchResultsControllerDidCancel(_ controller: UIViewController)
}


