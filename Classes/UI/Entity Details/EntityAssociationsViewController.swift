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
            associations = (entity as? Person)?.knownAssociates ?? [] // TODO: Refactor for all associations.
        }
    }
    
    private var associations: [KnownAssociate] = [] {
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
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
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
        let cell = collectionView.dequeueReusableCell(of: EntityCollectionViewCell.self, for: indexPath)
        let associate = associations[indexPath.item]
        
        // TEMPORARY: This is a massive hack.
        
        cell.style = .hero
        cell.titleLabel.text = associate.fullName
        
        if let fullName = associate.fullName {
            let initials = fullName.components(separatedBy: .whitespaces).prefix(2).flatMap { $0.characters.first }
            if initials.isEmpty {
                cell.thumbnailView.imageView.image = nil
            } else {
                cell.thumbnailView.imageView.image = generateInitialThumbnail(initials: String(initials.reversed()))
                cell.thumbnailView.imageView.contentMode = .scaleAspectFill
            }
        } else {
            cell.thumbnailView.imageView.image = nil
        }
        
        cell.tintColor = UIColor(white: 0.2, alpha: 1.0)
        
        if let date = associate.dateOfBirth {
            cell.subtitleLabel.text = DateFormatter.mediumNumericDate.string(from: date)
        } else {
            cell.subtitleLabel.text = nil
        }
        
        cell.detailLabel.text = associate.knownAssociateDescription
        
        return cell
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets {
        var inset = super.collectionView(collectionView, layout: layout, insetForSection: section, givenSectionWidth: width)
        inset.top    = 4.0
        inset.bottom = 0
        return inset
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        return EntityCollectionViewCell.minimumContentWidth(forStyle: .hero)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        return EntityCollectionViewCell.minimumContentHeight(forStyle: .hero, compatibleWith: traitCollection) - 12.0
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
