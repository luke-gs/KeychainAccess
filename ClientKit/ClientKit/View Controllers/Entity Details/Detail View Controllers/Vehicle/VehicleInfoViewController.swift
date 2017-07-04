//
//  VehicleInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit
import MPOLKit

open class VehicleInfoViewController: EntityDetailCollectionViewController {
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("VehicleInfoViewController does not support NSCoding.")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:       return 1
        case .registration: return RegistrationItem.count
        case .owner:        return OwnerItem.count
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
        let section = Section(rawValue: indexPath.section)!
        
        let title: String
        let subtitle: String
        let multiLineSubtitle: Bool
        
        switch section {
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
            
            return cell
        case .registration:
            let regoItem = RegistrationItem(rawValue: indexPath.item)!
            title    = regoItem.localizedTitle
            subtitle = regoItem.value(from: nil)
            multiLineSubtitle = false
        case .owner:
            let ownerItem = OwnerItem(rawValue: indexPath.item)!
            title    = ownerItem.localizedTitle
            subtitle = ownerItem.value(for: nil)
            multiLineSubtitle = ownerItem.wantsMultiLineDetail
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.isEditable = false
        
        cell.titleLabel.text = title
        cell.valueLabel.text = subtitle
        cell.valueLabel.numberOfLines = multiLineSubtitle ? 0 : 1
        
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
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        
        let extraLargeText: Bool
        
        switch traitCollection.preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large, UIContentSizeCategory.unspecified:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat
        let maxColumnCount: Int
        
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return collectionView.bounds.width
        case .registration:
            switch RegistrationItem(rawValue: indexPath.item)! {
            case .make, .model, .vin:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 3
            default:
                minimumWidth = extraLargeText ? 180.0 : 115.0
                maxColumnCount = 4
            }
        case .owner:
            switch OwnerItem(rawValue: indexPath.item)! {
            case .address:
                return collectionView.bounds.width
            default:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 3
            }
        }
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: traitCollection.currentDisplayScale)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let value: String
        
        let wantsMultiLineValue: Bool
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", descriptionPlaceholder: nil, additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        case .registration:
            let regoItem = RegistrationItem(rawValue: indexPath.item)
            title    = regoItem?.localizedTitle ?? ""
            value = regoItem?.value(from: nil) ?? ""
            wantsMultiLineValue = false
        case .owner:
            let ownerItem = OwnerItem(rawValue: indexPath.item)
            title    = ownerItem?.localizedTitle ?? ""
            value = ownerItem?.value(for: nil) ?? ""
            wantsMultiLineValue = ownerItem?.wantsMultiLineDetail ?? false
        }
        
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: value, inWidth: itemWidth, compatibleWith: traitCollection, singleLineValue: wantsMultiLineValue == false)
    }
    
    
    // MARK: - Private
    
    private enum Section: Int {
        case header
        case registration
        case owner
        
        static let count = 3
        
        var localizedTitle: String {
            switch self {
            case .header:       return NSLocalizedString("LAST UPDATED",         bundle: .mpolKit, comment: "")
            case .registration: return NSLocalizedString("REGISTRATION DETAILS", bundle: .mpolKit, comment: "")
            case .owner:        return NSLocalizedString("REGISTERED OWNER",     bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private enum RegistrationItem: Int {
        case make
        case model
        case vin
        case manufactured
        case transmission
        case color1
        case color2
        case engine
        case seating
        case weight
        
        static let count: Int = 10
        
        var localizedTitle: String {
            switch self {
            case .make:         return NSLocalizedString("Make",               bundle: .mpolKit, comment: "")
            case .model:        return NSLocalizedString("Model",              bundle: .mpolKit, comment: "")
            case .vin:          return NSLocalizedString("VIN/Chassis Number", bundle: .mpolKit, comment: "")
            case .manufactured: return NSLocalizedString("Manufactured in",    bundle: .mpolKit, comment: "")
            case .transmission: return NSLocalizedString("Transmission",       bundle: .mpolKit, comment: "")
            case .color1:       return NSLocalizedString("Colour 1",           bundle: .mpolKit, comment: "")
            case .color2:       return NSLocalizedString("Colour 2",           bundle: .mpolKit, comment: "")
            case .engine:       return NSLocalizedString("Engine",             bundle: .mpolKit, comment: "")
            case .seating:      return NSLocalizedString("Seating",            bundle: .mpolKit, comment: "")
            case .weight:       return NSLocalizedString("Curb weight",        bundle: .mpolKit, comment: "")
            }
        }
        
        func value(from vehicle: Any?) -> String {
            // TODO: Fill these details in
            switch self {
            case .make:         return "Tesla"
            case .model:        return "Model S P100D"
            case .vin:          return "1FUJA6CG47LY64774"
            case .manufactured: return "2020"
            case .transmission: return "Automatic"
            case .color1:       return "Black"
            case .color2:       return "Silver"
            case .engine:       return "Electric"
            case .seating:      return "2 + 3"
            case .weight:       return "2,239 kg"
            }
        }
    }
    
    private enum OwnerItem: Int {
        case name
        case dob
        case gender
        case address
        
        static let count: Int = 4
        
        var localizedTitle: String {
            switch self {
            case .name:    return NSLocalizedString("Name",          bundle: .mpolKit, comment: "")
            case .dob:     return NSLocalizedString("Date of Birth", bundle: .mpolKit, comment: "")
            case .gender:  return NSLocalizedString("Gender",        bundle: .mpolKit, comment: "")
            case .address: return NSLocalizedString("Address",       bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for vehicle: Any?) -> String {
            // TODO: Fill these details in
            switch self {
            case .name:    return "Citizen, John R"
            case .dob:     return "08/05/1987 (29)"
            case .gender:  return "Male"
            case .address: return "8 Catherine Street, Southbank VIC 3006"
            }
        }
        
        var wantsMultiLineDetail: Bool {
            switch self {
            case .address: return true
            default:       return false
            }
        }
    }
    
    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
        
    }
}
