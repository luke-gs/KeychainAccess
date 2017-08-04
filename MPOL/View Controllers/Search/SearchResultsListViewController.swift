//
//  SearchResultsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 5/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit
import Unbox

fileprivate let alertCellID = "alertCell"

class SearchResultsListViewController: FormCollectionViewController {
    
    weak var delegate: SearchResultsDelegate?
    
    @NSCopying var searchRequest: SearchRequest? {
        didSet {
            searchFieldButton?.text = searchRequest?.searchText
        }
    }
    
    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue { return }
            
            listStateItem.image = AssetManager.shared.image(forKey: wantsThumbnails ? .list : .thumbnail)
            
            if traitCollection.horizontalSizeClass != .compact {
                collectionView?.reloadData()
            }
        }
    }
    
    private let listStateItem = UIBarButtonItem(image: AssetManager.shared.image(forKey: .list), style: .plain, target: nil, action: nil)
    
    private var searchFieldButton: SearchFieldButton?
    
    private var alertEntities: [Entity] = []
    private var alertExpanded = false
    
    private var dataSourceResults: [DataSourceResult] = []
    
    
    override init() {
        super.init()
        
        title = NSLocalizedString("Search Results", comment: "Navigation Bar Title") // Temp
        
        let url = Bundle.mpolKit.url(forResource: "Person_25625aa4-3394-48e2-8dbc-2387498e16b0", withExtension: "json", subdirectory: "Mock JSONs")!
        let data = try! Data(contentsOf: url)
        let person1: [Person] = [try! unbox(data: data)]
        
        alertEntities = person1
        dataSourceResults = [DataSourceResult(name: "LEAP", isExpanded: true, entities: person1)]

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
        searchFieldButton.text = searchRequest?.searchText
        searchFieldButton.addTarget(self, action: #selector(searchFieldButtonDidSelect), for: .primaryActionTriggered)
        view.addSubview(searchFieldButton)
        self.searchFieldButton = searchFieldButton
        
        super.viewDidLoad()
        
        guard let view = self.view, let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(EntityCollectionViewCell.self, forCellWithReuseIdentifier: alertCellID)
        collectionView.register(SearchEntityListCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        NSLayoutConstraint.activate([
            searchFieldButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchFieldButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchFieldButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
        ])
    }
    
    open override func viewDidLayoutSubviews() {
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
    
    override func apply(_ theme: Theme) {
        super.apply(theme)
        
        guard let searchField = searchFieldButton else { return }
        
        searchField.backgroundColor = theme.color(forKey: .searchFieldBackground)
        searchField.fieldColor = theme.color(forKey: .searchField)
        searchField.textColor  = primaryTextColor
        searchField.placeholderTextColor = placeholderTextColor
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sectionCount = dataSourceResults.count
        if alertEntities.isEmpty == false {
            sectionCount += 1
        }
        return sectionCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: section)
        
        if adjustedSection < 0 {
        let alertCount = alertEntities.count
            return alertExpanded ? alertCount : 0
        }
        
        let dataSource = dataSourceResults[adjustedSection]
        return dataSource.isExpanded ? dataSource.entities.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            let isExpanded: Bool
            
            let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: indexPath.section)
            
            if adjustedSection < 0 {
                let alertCount = alertEntities.count
                header.text = String.localizedStringWithFormat(NSLocalizedString("%d Alert(s)", comment: ""), alertCount).uppercased(with: .current)
                isExpanded = alertExpanded
            } else {
                let dataSourceResult = dataSourceResults[adjustedSection]
                header.text = String.localizedStringWithFormat(NSLocalizedString("%1$d Result(s) in %2$@", comment: ""), dataSourceResult.entities.count, dataSourceResult.name).uppercased(with: .current)
                isExpanded = dataSourceResult.isExpanded
            }
            
            header.showsExpandArrow = true
            header.isExpanded = isExpanded
            
            header.tapHandler = { [weak self] (headerView, indexPath) in
                guard let `self` = self else { return }
                
                let shouldBeExpanded = headerView.isExpanded == false
                
                var adjustedSection = indexPath.section
                let alertCount = self.alertEntities.count
                
                if alertCount > 0 {
                    adjustedSection -= 1
                }
                
                if adjustedSection < 0 {
                    self.alertExpanded = shouldBeExpanded
                } else {
                    self.dataSourceResults[adjustedSection].isExpanded = shouldBeExpanded
                }
                self.collectionView?.reloadData()
            }
            
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = self.entity(at: indexPath)
        
        let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: indexPath.section)
        
        if adjustedSection >= 0 && (wantsThumbnails == false || traitCollection.horizontalSizeClass == .compact) {
            let cell = collectionView.dequeueReusableCell(of: SearchEntityListCell.self, for: indexPath)
            cell.titleLabel.text    = entity.summary
            
            let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
            cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
            cell.thumbnailView.configure(for: entity, size: .small)
            cell.alertColor       = entity.alertLevel?.color
            cell.actionCount      = entity.actionCount
            cell.highlightStyle   = .fade
            cell.sourceLabel.text = entity.source?.localizedBadgeTitle
            cell.accessoryView = cell.accessoryView as? FormAccessoryView ?? FormAccessoryView(style: .disclosure)
            
            return cell
        }
        
        let cell: EntityCollectionViewCell
        let style: EntityCollectionViewCell.Style
        
        if adjustedSection < 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: alertCellID, for: indexPath) as! EntityCollectionViewCell
            style = .thumbnail
        } else {
            cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            style = .hero
        }
        cell.configure(for: entity, style: style)
        cell.highlightStyle   = .fade
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let listCell = cell as? SearchEntityListCell {
            listCell.titleLabel.textColor = primaryTextColor
            listCell.subtitleLabel.textColor = secondaryTextColor
            listCell.separatorColor = separatorColor
        } else {
            super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.searchResultsController(self, didSelectEntity: entity(at: indexPath))
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
        let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: indexPath.section)
        
        if adjustedSection < 0 {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .thumbnail)
        }
        
        if wantsThumbnails && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
        }
        
        return collectionView.bounds.width
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: indexPath.section)

        if adjustedSection < 0 {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .thumbnail, compatibleWith: traitCollection) - 12.0
        }
        
        if wantsThumbnails && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection) - 12.0
        }
        
        return SearchEntityListCell.minimumContentHeight(compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private methods
    
    @objc private func searchFieldButtonDidSelect() {
        delegate?.searchResultsController(self, didRequestToEdit: searchRequest)
    }
    
    @objc private func backButtonItemDidSelect() {
        delegate?.searchResultsControllerDidCancel(self)
    }
    
    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }
    
    @objc private func entity(at indexPath: IndexPath) -> Entity {
        
        let adjustedSection = adjustedSectionIndex(forDataSourceSectionIndex: indexPath.section)
        
        if adjustedSection < 0 {
            return alertEntities[indexPath.item]
        }
        
        return dataSourceResults[adjustedSection].entities[indexPath.item]
    }
    
    private func adjustedSectionIndex(forDataSourceSectionIndex: Int) -> Int {
        var adjustedSection = forDataSourceSectionIndex
        let alertCount = alertEntities.count
        
        if alertCount > 0 {
            adjustedSection -= 1
        }
        
        return adjustedSection
    }
    
}

fileprivate struct DataSourceResult {
    var name: String
    var isExpanded: Bool
    var entities: [Entity]
}

protocol SearchResultsDelegate: class {
    
    func searchResultsController(_ controller: UIViewController, didRequestToEdit searchRequest: SearchRequest?)
    
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: Entity)
    
    func searchResultsControllerDidCancel(_ controller: UIViewController)
    
}

