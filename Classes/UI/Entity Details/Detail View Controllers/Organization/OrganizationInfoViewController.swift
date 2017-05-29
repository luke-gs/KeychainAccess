//
//  OrganizationInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit

open class OrganizationInfoViewController: EntityDetailCollectionViewController {
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", comment: "")
        
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
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:   return super.collectionView(collectionView, numberOfItemsInSection: section)
        case .details:  return DetailItem.count
        case .aliases:  return 1
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            
            let section = Section(rawValue: indexPath.section)!
            
            if section == .header {
                let lastUpdatedString: String
                if let lastUpdated = entity?.lastUpdated {
                    lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
                } else {
                    lastUpdatedString = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
                }
                headerView.text = NSLocalizedString("LAST UPDATED: ", bundle: .mpolKit, comment: "") + lastUpdatedString
            } else {
                headerView.text = Section(rawValue: indexPath.section)?.localizedTitle
            }
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let title: String?
        let subtitle: String?
        let multiLineLabel: Bool
        
        switch Section(rawValue: indexPath.section)! {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            /// Temp updates
            cell.thumbnailView.configure(for: entity, size: .large)
            if cell.thumbnailView.allTargets.contains(self) == false {
                cell.thumbnailView.isEnabled = true
                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
            }
            
            cell.sourceLabel.text = entity?.source?.localizedBadgeTitle
            cell.titleLabel.text = "Citizen, John R."
            cell.subtitleLabel.text = "08/05/1987 (29 Male)"
            cell.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            cell.additionalDetailsButton.setTitle("4 MORE DESCRIPTIONS", for: .normal)
            
            return cell
        case .details:
            let detailItem = DetailItem(rawValue: indexPath.item)
            title    = detailItem?.localizedTitle
            subtitle = detailItem?.value(for: nil)
            multiLineLabel = detailItem?.wantsMultiLineSubtitle ?? false
        case .aliases:
            title    = "Alernative name"
            subtitle = "Orion Central Bank Melbourne"
            multiLineLabel = false
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.isEditable = false
        
        cell.titleLabel.text = title
        cell.valueLabel.text = subtitle
        cell.valueLabel.numberOfLines = multiLineLabel ? 0 : 1
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = secondaryTextColor ?? .darkGray
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        
        let displayScale = traitCollection.currentDisplayScale
        
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return sectionWidth
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
        let value: String
        
        let wantsMultiLineValue: Bool
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", descriptionPlaceholder: nil, additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        case .details:
            let detailItem = DetailItem(rawValue: indexPath.item)
            title    = detailItem?.localizedTitle ?? ""
            value = detailItem?.value(for: nil) ?? ""
            wantsMultiLineValue = detailItem?.wantsMultiLineSubtitle ?? false
        case .aliases:
            title    = "Alernative name"
            value = "Orion Central Bank Melbourne"
            wantsMultiLineValue = false
        }
        
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: value, inWidth: itemWidth, compatibleWith: traitCollection, singleLineValue: wantsMultiLineValue == false)
    }
    
    
    // MARK: - Enums
    
    private enum Section: Int {
        case header
        case details
        case aliases
        
        static let count = 3
        
        var localizedTitle: String {
            switch self {
            case .header:  return NSLocalizedString("LAST UPDATED",          bundle: .mpolKit, comment: "")
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
    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
    }
    
}
