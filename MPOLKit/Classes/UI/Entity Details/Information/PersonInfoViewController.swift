//
//  PersonInfoViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class PersonInfoViewController: EntityInfoViewController {
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(CollectionViewFormSubtitleCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .details:   return super.collectionView(collectionView, numberOfItemsInSection: section)
        case .addresses: return 2
        case .contact:   return 1
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && indexPath.section != 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormMPOLHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            
            switch Section(rawValue: indexPath.section)! {
            case .addresses:
                headerView.text = "ADDRESSES"
            case .contact:
                headerView.text = "CONTACT"
            default:
                headerView.text = nil
            }
            
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(rawValue: indexPath.section)!
        if section == .details { return super.collectionView(collectionView, cellForItemAt: indexPath) }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.emphasis = .subtitle
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 0
        
        switch section {
        case .addresses:
            cell.imageView.image = UIImage(named: "iconGeneralLocation", in: Bundle(for: PersonInfoViewController.self), compatibleWith: nil)
            if indexPath.item == 0 {
                cell.titleLabel.text = "Residential"
                cell.subtitleLabel.text = "8 Catherine Street, Southbank VIC 3006"
            } else {
                cell.titleLabel.text = "Work"
                cell.subtitleLabel.text = "285-287 Coventry Street, South Morang VIC 3205"
            }
        case .contact:
            cell.imageView.image = nil
            cell.titleLabel.text = "Email address"
            cell.subtitleLabel.text = "john.citizen@gmail.com"
        default:
            break
        }
        
        return cell
    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        if section == 0 {
            return super.collectionView(collectionView, layout: layout, heightForHeaderInSection:section, givenSectionWidth: width)
        }
            
        return CollectionViewFormMPOLHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let subtitle: String
        let image: UIImage?
        
        switch Section(rawValue: indexPath.section)! {
        case .details:
            return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
        case .addresses:
            image = UIImage(named: "iconGeneralLocation", in: Bundle(for: PersonInfoViewController.self), compatibleWith: nil)
            if indexPath.item == 0 {
                title = "Residential"
                subtitle = "8 Catherine Street, Southbank VIC 3006"
            } else {
                title = "Work"
                subtitle = "285-287 Coventry Street, South Morang VIC 3205"
            }
        case .contact:
            image = nil
            title = "Email address"
            subtitle = "john.citizen@gmail.com"
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: .subtitle, singleLineSubtitle: false)
    }
    
    
    // MARK: - Section enum
    
    private enum Section: Int {
        case details
        case addresses
        case contact
        
        static let count = 3
    }
    
}
