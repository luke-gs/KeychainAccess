//
//  OrganizationInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit

open class OrganizationInfoViewController: EntityInfoViewController {

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
        case .details:  return DetailItem.count
        case .aliases:  return 1
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.emphasis = .subtitle
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 1
        
        switch Section(rawValue: indexPath.section)! {
        case .details:
            let detailItem = DetailItem(rawValue: indexPath.item)
            cell.titleLabel.text    = detailItem?.localizedTitle
            cell.subtitleLabel.text = detailItem?.value(for: nil)
            cell.subtitleLabel.numberOfLines = detailItem?.wantsMultiLineSubtitle ?? false ? 1 : 0
        case .aliases:
            cell.titleLabel.text    = "Alernative name"
            cell.subtitleLabel.text = "Orion Central Bank Melbourne"
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
        
        let displayScale = traitCollection.currentDisplayScale
        
        switch Section(rawValue: indexPath.section)! {
        case .details:
            let columnCount = min(3, layout.columnCountForSection(withMinimumItemContentWidth: 180.0, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets))
            if columnCount <= 1 { return sectionWidth }
            
            switch DetailItem(rawValue: indexPath.item)! {
            case .address, .remarks: return sectionWidth
            case .type:
                return layout.itemContentWidth(fillingColumns: columnCount - 1, inSectionWithColumns: columnCount, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: displayScale)
            case .effectiveFrom:
                return layout.columnContentWidth(forColumnCount: columnCount, inSectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: displayScale)
            }
        case .aliases:
            return sectionWidth
        }
        
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let subtitle: String
        
        let wantsMultiLineSubtitle: Bool
        switch Section(rawValue: indexPath.section)! {
        case .details:
            let detailItem = DetailItem(rawValue: indexPath.item)
            title    = detailItem?.localizedTitle ?? ""
            subtitle = detailItem?.value(for: nil) ?? ""
            wantsMultiLineSubtitle = detailItem?.wantsMultiLineSubtitle ?? false
        case .aliases:
            title    = "Alernative name"
            subtitle = "Orion Central Bank Melbourne"
            wantsMultiLineSubtitle = false
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .subtitle, singleLineSubtitle: wantsMultiLineSubtitle == false)
    }
    
    
    // MARK: - Enums
    
    private enum Section: Int {
        case details
        case aliases
        
        static let count = 2
        
        var localizedTitle: String {
            switch self {
            case .details: return NSLocalizedString("BUSINESS/ORGANISATION", bundle: .mpolKit, comment: "")
            case .aliases: return NSLocalizedString("ALIASES",               bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private enum DetailItem: Int {
        case type
        case effectiveFrom
        case address
        case remarks
        
        static let count = 4
        
        var localizedTitle: String {
            switch self {
            case .type:          return NSLocalizedString("Type",           bundle: .mpolKit, comment: "")
            case .effectiveFrom: return NSLocalizedString("Effective from", bundle: .mpolKit, comment: "")
            case .address:       return NSLocalizedString("Address",        bundle: .mpolKit, comment: "")
            case .remarks:       return NSLocalizedString("Remarks",        bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for organization: Any?) -> String? {
            switch self {
            case .type:          return "Financial Institution"
            case .effectiveFrom: return "20/02/20"
            case .address:       return "65 Collins St Melbourne Vic 3000"
            case .remarks:       return "-"
            }
        }
        
        var wantsMultiLineSubtitle: Bool {
            switch self {
            case .remarks: return true
            default:       return false
            }
        }
        
    }
    
}
