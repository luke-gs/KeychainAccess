//
//  EntityInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityInfoViewController: EntityDetailCollectionViewController {
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = "Information"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.register(EntityDetailCollectionViewCell.self)
            collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 && kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            header.showsExpandArrow = false
            header.tapHandler       = nil
            header.text = "LAST UPDATED: " + "NEVER"
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 && indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            /// Temp updates
            cell.thumbnailView.configure(for: NSObject())
            if cell.thumbnailView.allTargets.contains(self) == false {
                cell.thumbnailView.isEnabled = true
                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
            }
            
            cell.sourceLabel.text = entity?.source?.localizedUppercase
            cell.titleLabel.text = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            cell.additionalDetailsButton.setTitle("4 MORE DESCRIPTIONS", for: .normal)
            
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = secondaryTextColor ?? .darkGray
        }
    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout methods
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        if section == 0 {
            return CollectionViewFormExpandingHeaderView.minimumHeight
        }
        return super.collectionView(collectionView, layout: layout, heightForHeaderInSection: section, givenSectionWidth: width)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.item == 0 {
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        }
        return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
    }
    
//    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, separatorStyleForItemAt indexPath: IndexPath) -> CollectionViewFormLayout.SeparatorStyle {
//        if indexPath.section == 0 && indexPath.item == 0 {
//            return .hidden
//        }
//        return .automatic
//    }
    
    
    // MARK: - Additional details action handler
    
    open func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    open func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
        
    }
    
}
