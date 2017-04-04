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
        collectionView?.register(CollectionViewFormProgressCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:   return super.collectionView(collectionView, numberOfItemsInSection: section)
        case .licences:  return LicenceItem.count
        case .addresses: return 2
        case .contact:   return 1
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && indexPath.section != 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            headerView.text = Section(rawValue: indexPath.section)?.localizedTitle
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(rawValue: indexPath.section)!
        if section == .header { return super.collectionView(collectionView, cellForItemAt: indexPath) }
        
        if section == .licences, let item = LicenceItem(rawValue: indexPath.item), item == .validity {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormProgressCell.self, for: indexPath)
            cell.emphasis = .subtitle
            cell.isEditableField = false
            cell.titleLabel.text    = item.localizedTitle
            cell.subtitleLabel.text = item.value(for: nil)
            cell.progressView.progressTintColor = #colorLiteral(red: 0.3001902103, green: 0.6874542236, blue: 0.311791122, alpha: 1)
            cell.progressView.progress = 0.5
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.emphasis = .subtitle
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 0
        
        switch section {
        case .licences:
            cell.imageView.image = nil
            
            let licenceItem = LicenceItem(rawValue: indexPath.item)
            cell.titleLabel.text = licenceItem?.localizedTitle
            cell.subtitleLabel.text = licenceItem?.value(for: nil)
            cell.subtitleLabel.numberOfLines = 1
        case .addresses:
            cell.imageView.image = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
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
            
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        if let section = Section(rawValue: indexPath.section),
            section == .licences,
            let licenceItem = LicenceItem(rawValue: indexPath.item),
            licenceItem != .validity {
            return layout.columnContentWidth(forMinimumItemContentWidth: 180.0, maximumColumnCount: 3, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets)
        }
        return sectionWidth
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let subtitle: String
        let image: UIImage?
        
        let wantsSingleLineSubtitle: Bool
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
        case .licences:
            let licenceItem = LicenceItem(rawValue: indexPath.item)
            title    = licenceItem?.localizedTitle ?? ""
            subtitle = licenceItem?.value(for: nil) ?? ""
            image    = nil
            wantsSingleLineSubtitle = true
        case .addresses:
            image = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
            if indexPath.item == 0 {
                title = "Residential"
                subtitle = "8 Catherine Street, Southbank VIC 3006"
            } else {
                title = "Work"
                subtitle = "285-287 Coventry Street, South Morang VIC 3205"
            }
            wantsSingleLineSubtitle = false
        case .contact:
            image = nil
            title = "Email address"
            subtitle = "john.citizen@gmail.com"
            wantsSingleLineSubtitle = false
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: .subtitle, singleLineSubtitle: wantsSingleLineSubtitle)
    }
    
    
    // MARK: - Enums
    
    private enum Section: Int {
        case header
        case licences
        case addresses
        case contact
        
        static let count = 4
        
        var localizedTitle: String {
            switch self {
            case .header:    return NSLocalizedString("LAST UPDATED", bundle: .mpolKit, comment: "")
            case .licences:  return NSLocalizedString("LICENCES",     bundle: .mpolKit, comment: "")
            case .addresses: return NSLocalizedString("ADDRESSES",    bundle: .mpolKit, comment: "")
            case .contact:   return NSLocalizedString("CONTACT",      bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private enum LicenceItem: Int {
        case licenceClass
        case licenceType
        case number
        case validity
        
        static let count: Int = 4
        
        var localizedTitle: String {
            switch self {
            case .licenceClass:  return NSLocalizedString("Class",          bundle: .mpolKit, comment: "")
            case .licenceType:   return NSLocalizedString("Type",           bundle: .mpolKit, comment: "")
            case .number:        return NSLocalizedString("Licence number", bundle: .mpolKit, comment: "")
            case .validity:      return NSLocalizedString("Valid until",    bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for licence: Any?) -> String {
            // TODO: Fill these details in
            switch self {
            case .licenceClass:  return "Motor Vehicle"
            case .licenceType:   return "Open Licence"
            case .number:        return "0123456789"
            case .validity:      return "15/05/17"
            }
        }
    }
    
}
