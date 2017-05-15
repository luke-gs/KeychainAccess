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
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityInfoHeaderView.self, forSupplementaryViewOfKind: collectionElementKindGlobalHeader)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == collectionElementKindGlobalHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: EntityInfoHeaderView.self, for: indexPath)
            header.layoutMargins = formLayout.itemLayoutMargins
            header.imageView.image = #imageLiteral(resourceName: "Avatar 1")
            header.sourceLabel.text = "DATA SOURCE 1"
            header.titleLabel.text = "Citizen, John R."
            header.subtitleLabel.text = "08/05/1987 (29 Male)"
            header.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            header.additionalDetailsButton.setTitle("4 MORE DESCRIPTIONS", for: .normal)
            header.alertColor = AlertLevel.high.color
            header.additionalDetailsButtonActionHandler = { [weak self] in self?.headerDidSelectAdditionalDetails($0) }
            return header
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate methods
    
//    open override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout methods
    
    public func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat {
        let contentHeight = EntityInfoHeaderView.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: collectionView.bounds.width, compatibleWith: traitCollection)
        let insets = layout.itemLayoutMargins
        return contentHeight + insets.top + insets.bottom
    }
    
    
    // MARK: - Additional details action handler
    
    private func headerDidSelectAdditionalDetails(_ header: EntityInfoHeaderView) {
    }
    
}
