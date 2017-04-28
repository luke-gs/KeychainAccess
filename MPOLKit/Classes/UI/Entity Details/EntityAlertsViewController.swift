//
//  EntityAlertsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAlertsViewController: FormCollectionViewController {
    
    private var statusDotCache: [AlertLevel: UIImage] = [:]
    
    public override init() {
        super.init()
        title = "Alerts"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAlert",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAlertFilled", in: .mpolKit, compatibleWith: nil)
        sidebarItem.count = 5
        sidebarItem.alertColor = AlertLevel.medium.color
        
        // By default, form layouts have a slight vertical adjustment downwards in their layout margins
        // to make fields look right in forms. To make them look like rows, we need to adjust the margins
        // so they're equal.
        var itemLayoutMargins = formLayout.itemLayoutMargins
        itemLayoutMargins.bottom = itemLayoutMargins.top
        formLayout.itemLayoutMargins = itemLayoutMargins
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormDetailCell.self)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormDetailCell.self, for: indexPath)
        
        let alertLevel = AlertLevel(rawValue: indexPath.item % 3 + 1)!
        if let cachedImage = statusDotCache[alertLevel] {
            cell.imageView.image = cachedImage
        } else {
            let image = UIImage.statusDot(withColor: alertLevel.color)
            statusDotCache[alertLevel] = image
            cell.imageView.image = image
        }
        
        cell.titleLabel.text    = "Wanted For Questioning"
        cell.subtitleLabel.text = "Effective from 21/01/15 - 21/12/14"
        cell.detailLabel.text   = "Individual is wanted for questioning in connection to a confrontation that happed at the Royal Motel, 133-155 Kingsclere Avenue, Keysborough VIC 3173. The event took place on..."
        
        cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.text = "5 ACTIVE ALERTS"
            header.showsExpandArrow = true
            header.isExpanded = true
            return header
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let alertCell = cell as? CollectionViewFormDetailCell {
            alertCell.titleLabel.textColor    = primaryTextColor
            alertCell.subtitleLabel.textColor = secondaryTextColor
            alertCell.detailLabel.textColor   = primaryTextColor
        }
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let height = CollectionViewFormDetailCell.minimumContentHeight(withImageSize: UIImage.statusDotFrameSize, compatibleWith: traitCollection)
        
        return height
    }
    
}

