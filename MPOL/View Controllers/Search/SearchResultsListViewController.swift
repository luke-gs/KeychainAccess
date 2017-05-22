//
//  SearchResultsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 5/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import Unbox

fileprivate let alertCellID = "alertCell"

class SearchResultsListViewController: FormCollectionViewController {
    
    weak var delegate: SearchResultsDelegate?
    
    private var wantsThumbnails: Bool = true {
        didSet {
            if wantsThumbnails == oldValue { return }
            
            listStateItem.image = wantsThumbnails ? #imageLiteral(resourceName: "iconNavBarList") : #imageLiteral(resourceName: "iconNavBarThumbnails")
            
            if traitCollection.horizontalSizeClass != .compact {
                collectionView?.reloadData()
            }
        }
    }
    
    private let listStateItem = UIBarButtonItem(image: #imageLiteral(resourceName: "iconNavBarList"), style: .plain, target: nil, action: nil)
    
    private var alertEntities: [Entity] = []
    private var alertExpanded = true
    
    private var dataSourceResults: [DataSourceResult] = []
    
    
    override init() {
        super.init()
        
        let bundle = Bundle(for: Person.self)
        let url = bundle.url(forResource: "Person_25625aa4-3394-48e2-8dbc-2387498e16b0", withExtension: "json", subdirectory: "Mock JSONs")!
        let data = try! Data(contentsOf: url)
        let person1: Person = try! unbox(data: data)
        let person2: Person = try! unbox(data: data)
        let person3: Person = try! unbox(data: data)
        
        alertEntities = [person1, person2, person3]
        dataSourceResults = [DataSourceResult(name: "LEAP", isExpanded: true, entities: alertEntities)]

        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.5, left: 8.0, bottom: 14.5, right: 8.0)
        formLayout.distribution = .none
        
        listStateItem.target = self
        listStateItem.action = #selector(toggleThumbnails)
        listStateItem.imageInsets = .zero
        navigationItem.rightBarButtonItems = [listStateItem]
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.register(EntityCollectionViewCell.self)
            collectionView.register(EntityCollectionViewCell.self, forCellWithReuseIdentifier: alertCellID)
            collectionView.register(SearchEntityListCell.self)
            collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        }
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
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sectionCount = dataSourceResults.count
        if alertEntities.isEmpty == false {
            sectionCount += 1
        }
        return sectionCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var adjustedSection = section
        
        let alertCount = alertEntities.count
        if alertCount > 0 {
            if section == 0 {
                return alertExpanded ? alertCount : 0
            } else {
                adjustedSection -= 1
            }
        }
        
        let dataSource = dataSourceResults[adjustedSection]
        return dataSource.isExpanded ? dataSource.entities.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            // TODO: Localize
            let count: Int
            let sectionText: String
            let isExpanded: Bool
            
            var adjustedSection = indexPath.section
            let alertCount = alertEntities.count
            
            if alertCount > 0 {
                adjustedSection -= 1
            }
            
            if adjustedSection < 0 {
                count = alertCount
                sectionText = count == 1 ? " ALERT" : " ALERTS"
                isExpanded = alertExpanded
            } else {
                let dataSourceResult = dataSourceResults[adjustedSection]
                count = dataSourceResult.entities.count
                sectionText = String(format: (count == 1 ? " RESULT FROM %@" : " RESULTS FROM %@"), dataSourceResult.name.uppercased())
                isExpanded = dataSourceResult.isExpanded
            }
            
            header.showsExpandArrow = true
            header.isExpanded = isExpanded
            header.text = (count == 0 ? "NO" : String(describing: count)) + sectionText
            
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
        
        if indexPath.section != 0 && (wantsThumbnails == false || traitCollection.horizontalSizeClass == .compact) {
            let cell = collectionView.dequeueReusableCell(of: SearchEntityListCell.self, for: indexPath)
            cell.titleLabel.text    = entity.summary
            
            let subtitleComponents = [entity.summaryDetail1, entity.summaryDetail2].flatMap({$0})
            cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
            cell.thumbnailView.configure(for: entity)
            cell.alertColor       = entity.alertLevel?.color
            cell.actionCount      = entity.actionCount
            cell.highlightStyle   = .fade
            cell.sourceLabel.text = entity.source?.localizedBadgeTitle
            cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
            
            return cell
        }
        
        let cell: EntityCollectionViewCell
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: alertCellID, for: indexPath) as! EntityCollectionViewCell
            cell.style = .thumbnail
        } else {
            cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            cell.style              = .hero
            cell.titleLabel.text    = entity.summary
            cell.subtitleLabel.text = entity.summaryDetail1
            cell.detailLabel.text   = entity.summaryDetail2
        }
        cell.thumbnailView.configure(for: entity)
        cell.alertColor       = Alert.Level.high.color
        cell.actionCount      = entity.actionCount
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = entity.source?.localizedBadgeTitle
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
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section, givenSectionWidth: width)
        inset.top    = 4.0
        inset.bottom = 0
        return inset
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        if indexPath.section == 0 {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .thumbnail)
        }
        
        if wantsThumbnails && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
        }
        
        return sectionWidth
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .thumbnail, compatibleWith: traitCollection) - 12.0
        }
        
        if wantsThumbnails && traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection) - 12.0
        }
        
        return SearchEntityListCell.minimumContentHeight(compatibleWith: traitCollection)
    }
    
    
    // MARK: - Private methods
    
    @objc private func toggleThumbnails() {
        wantsThumbnails = !wantsThumbnails
    }
    
    @objc private func entity(at indexPath: IndexPath) -> Entity {
        var adjustedSection = indexPath.section
        if alertEntities.isEmpty == false {
            if adjustedSection == 0 {
                return alertEntities[indexPath.item]
            } else {
                adjustedSection -= 1
            }
        }
        return dataSourceResults[adjustedSection].entities[indexPath.item]
    }
    
}

fileprivate struct DataSourceResult {
    var name: String
    var isExpanded: Bool
    var entities: [Entity]
}

protocol SearchResultsDelegate: class {
    
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: Entity)
    
}
