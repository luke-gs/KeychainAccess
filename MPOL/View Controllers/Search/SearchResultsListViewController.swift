//
//  SearchResultsListViewController.swift
//  MPOL
//
//  Created by Rod Brown on 5/4/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

private let alertCellID = "alertCell"

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
    
    fileprivate var alertEntities = [NSObject(), NSObject(), NSObject(), NSObject()]
    fileprivate var alertExpanded = true
    
    fileprivate var dataSourceResults: [DataSourceResult] = [
        DataSourceResult(name: "Data Source 1", isExpanded: true, items: [NSObject(), NSObject(), NSObject(), NSObject()]),
        DataSourceResult(name: "Data Source 2", isExpanded: true, items: [NSObject(), NSObject(), NSObject(), NSObject()])
    ]
    
    
    override init() {
        super.init()

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
    
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSourceResults.count + 1 // 1 for the alerts section
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return alertExpanded ? alertEntities.count : 0 }
        
        let dataSource = dataSourceResults[section - 1]
        
        return dataSource.isExpanded ? dataSource.items.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            
            // TODO: Localize
            let count: Int
            let sectionText: String
            let isExpanded: Bool
            if indexPath.section == 0 {
                count = alertEntities.count
                sectionText = count == 1 ? " ALERT" : " ALERTS"
                isExpanded = alertExpanded
            } else {
                let dataSourceResult = dataSourceResults[indexPath.section - 1]
                count = dataSourceResult.items.count
                sectionText = String(format: (count == 1 ? " RESULT FROM %@" : " RESULTS FROM %@"), dataSourceResult.name.uppercased())
                isExpanded = dataSourceResult.isExpanded
            }
            
            header.showsExpandArrow = true
            header.isExpanded = isExpanded
            header.text = (count == 0 ? "NO" : String(describing: count)) + sectionText
            
            header.tapHandler = { [weak self] (headerView, indexPath) in
                let shouldBeExpanded = headerView.isExpanded == false
                if indexPath.section == 0 {
                    self?.alertExpanded = shouldBeExpanded
                } else {
                    self?.dataSourceResults[indexPath.section - 1].isExpanded = shouldBeExpanded
                }
                self?.collectionView?.reloadData()
            }
            
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section != 0 && (wantsThumbnails == false || traitCollection.horizontalSizeClass == .compact) {
            let cell = collectionView.dequeueReusableCell(of: SearchEntityListCell.self, for: indexPath)
            cell.titleLabel.text    = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male) : Southbank VIC 3006"
            cell.imageView.image  = #imageLiteral(resourceName: "Avatar 1")
            cell.alertColor       = AlertLevel.high.color
            cell.alertCount       = 9
            cell.highlightStyle   = .fade
            cell.sourceLabel.text = "DS1"
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
            cell.titleLabel.text    = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.detailLabel.text   = "Southbank VIC 3006"
        }
        cell.imageView.image  = #imageLiteral(resourceName: "Avatar 1")
        cell.alertColor       = AlertLevel.high.color
        cell.alertCount       = 9
        cell.highlightStyle   = .fade
        cell.sourceLabel.text = "DS1"
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
        delegate?.searchResultsController(self, didSelectEntity: nil)
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
    
}

fileprivate struct DataSourceResult {
    var name: String
    var isExpanded: Bool
    var items: [Any]
}

protocol SearchResultsDelegate: class {
    
    func searchResultsController(_ controller: UIViewController, didSelectEntity entity: Any?)
    
}
