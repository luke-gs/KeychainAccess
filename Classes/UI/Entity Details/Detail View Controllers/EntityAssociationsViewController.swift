//
//  EntityAssociationsViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class EntityAssociationsViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        didSet {
            updateNoContentSubtitle()
            associations = (entity as? Person)?.associatedPersons ?? [] // TODO: Refactor for all associations.
        }
    }
    
    private var associations: [Person] = [] {
        didSet {
            sidebarItem.count = UInt(associations.count)
            hasContent = associations.isEmpty == false
        }
    }
    
    
    public override init() {
        super.init()
        title = "Associations"
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralAssociation",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralAssociationFilled", in: .mpolKit, compatibleWith: nil)
        
        formLayout.itemLayoutMargins = UIEdgeInsets(top: 16.5, left: 8.0, bottom: 14.5, right: 8.0)
        formLayout.distribution = .none
        
        let filterIcon = UIBarButtonItem(image: UIImage(named: "iconFormFilter", in: .mpolKit, compatibleWith: nil), style: .plain, target: nil, action: nil)
        filterIcon.isEnabled = false
        navigationItem.rightBarButtonItem = filterIcon
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Associations Found", comment: "")
        updateNoContentSubtitle()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityCollectionViewCell.self)
        collectionView.register(EntityListCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isCompact = traitCollection.horizontalSizeClass == .compact
        if isCompact != (previousTraitCollection?.horizontalSizeClass == .compact) {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return associations.isEmpty ? 0 : 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return associations.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            let count = associations.count
            header.text = String(format: (count == 1 ? "%d PERSON" : "%d PEOPLE"), count)
            header.showsExpandArrow = false
            return header
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let associate = associations[indexPath.item]
        
        if isCompact {
            let cell = collectionView.dequeueReusableCell(of: EntityListCollectionViewCell.self, for: indexPath)
            cell.titleLabel.text    = associate.summary
            
            let subtitleComponents = [associate.summaryDetail1, associate.summaryDetail2].flatMap({$0})
            cell.subtitleLabel.text = subtitleComponents.isEmpty ? nil : subtitleComponents.joined(separator: " : ")
            cell.thumbnailView.configure(for: entity, size: .small)
            cell.alertColor       = associate.alertLevel?.color
            cell.actionCount      = associate.actionCount
            cell.highlightStyle   = .fade
            cell.sourceLabel.text = associate.source?.localizedBadgeTitle
            cell.accessoryView = cell.accessoryView as? FormDisclosureView ?? FormDisclosureView()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
            
            cell.configure(for: associate, style: .hero)
            cell.highlightStyle = .fade
            
            return cell
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    
    // MARK: - UICollectionViewDelegate methods
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let listCell = cell as? EntityListCollectionViewCell {
            listCell.titleLabel.textColor = primaryTextColor
            listCell.subtitleLabel.textColor = secondaryTextColor
            listCell.separatorColor = separatorColor
        } else {
            super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout methods
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section)
        inset.top    = 4.0
        inset.bottom = 0
        return inset
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        if traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
        }
        return collectionView.bounds.width
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        if traitCollection.horizontalSizeClass != .compact {
            return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection) - 12.0
        } else {
            return EntityListCollectionViewCell.minimumContentHeight(compatibleWith: traitCollection)
        }
    }
    
    
    

    
    private func updateNoContentSubtitle() {
        guard let label = noContentSubtitleLabel else { return }
        
        let entityDisplayName: String
        if let entity = entity {
            entityDisplayName = type(of: entity).localizedDisplayName.localizedLowercase
        } else {
            entityDisplayName = NSLocalizedString("entity", bundle: .mpolKit, comment: "")
        }
        
        label.text = String(format: NSLocalizedString("This %@ has no associations", bundle: .mpolKit, comment: ""), entityDisplayName)
    }
    
}
