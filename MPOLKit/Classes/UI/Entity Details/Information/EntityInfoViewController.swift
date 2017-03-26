//
//  EntityInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityInfoViewController: FormCollectionViewController {
    
    public override init() {
        super.init()
        title = "Information"
        
        let sidebarItem = self.sidebarItem
        let bundle = Bundle(for: FormCollectionViewController.self)
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: bundle, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: bundle, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.register(EntityDetailCollectionViewCell.self)
            collectionView.register(EntityImageHeaderView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)
            collectionView.register(CollectionViewFormMPOLHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
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
        
        if kind == collectionElementKindGlobalHeader {
            let globalHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: EntityImageHeaderView.self, for: indexPath)
            let borderedImageView = globalHeader.borderedImageView
            borderedImageView.imageView.image = #imageLiteral(resourceName: "Avatar 1")
            //borderedImageView.borderColor = AlertLevel.high.color
            return globalHeader
        } else if indexPath.section == 0 && kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormMPOLHeaderView.self, for: indexPath)
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
            cell.imageView.image = #imageLiteral(resourceName: "Avatar 1")
            cell.sourceLabel.text = "DATA SOURCE 1"
            cell.titleLabel.text = "Smith, Max R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            cell.additionalDetailsButton.setTitle("4 MORE DESCRIPTIONS", for: .normal)
            cell.alertColor = AlertLevel.high.color
            
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
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        if traitCollection.horizontalSizeClass == .compact {
            return collectionView.bounds.width * 0.6
        }
        return 0.0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        if section == 0 {
            return section == 0 ? CollectionViewFormMPOLHeaderView.minimumHeight : 0.0
        }
        return super.collectionView(collectionView, layout: layout, heightForHeaderInSection: section, givenSectionWidth: width)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        if indexPath.section == 0 && indexPath.item == 0 {
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection)
        }
        return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormMPOLLayout, separatorStyleForItemAt indexPath: IndexPath) -> CollectionViewFormMPOLLayout.SeparatorStyle {
        if indexPath.section == 0 && indexPath.item == 0 {
            return .hidden
        }
        return .automatic
    }
    
    
    // MARK: - Additional details action handler
    
    open func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
}


private class EntityImageHeaderView: UICollectionReusableView, DefaultReusable {
    
    let borderedImageView = BorderedImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        borderedImageView.frame = bounds
        borderedImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        borderedImageView.wantsRoundedCorners = false
        addSubview(borderedImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

