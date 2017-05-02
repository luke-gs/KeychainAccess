//
//  VehicleInfoViewController.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/3/17.
//
//

import UIKit

open class VehicleInfoViewController: EntityInfoViewController {
    
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
        case .header:       return super.collectionView(collectionView, numberOfItemsInSection: section)
        case .registration:  return RegistrationItem.count
        case .owner:         return OwnerItem.count
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
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.emphasis = .subtitle
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 1
        
        switch section {
        case .registration:
            let regoItem = RegistrationItem(rawValue: indexPath.item)
            cell.titleLabel.text    = regoItem?.localizedTitle
            cell.subtitleLabel.text = regoItem?.value(from: nil)
        case .owner:
            let ownerItem = OwnerItem(rawValue: indexPath.item)
            cell.titleLabel.text    = ownerItem?.localizedTitle
            cell.subtitleLabel.text = ownerItem?.value(for: nil)
            
            if ownerItem?.wantsMultiLineDetail ?? false {
                cell.subtitleLabel.numberOfLines = 0
            }
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
        
        let preferredContentSizeCategory: UIContentSizeCategory
        if #available(iOS 10, *) {
            let category = traitCollection.preferredContentSizeCategory
            preferredContentSizeCategory = category == UIContentSizeCategory.unspecified ? .large : category
        } else {
            // references to the shared application are banned in extensions but this actually still works
            // in apps and gets us the preferred content size. This is part of why they moved preferred
            // content size category into trait collections as it couldn't be accessed on UIApplication
            // in extensions (and MPOLKit is restrcted to extension-only API)
            preferredContentSizeCategory = (UIApplication.value(forKey: "sharedApplication") as! UIApplication).preferredContentSizeCategory
        }
        
        let extraLargeText: Bool
        
        switch preferredContentSizeCategory {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small, UIContentSizeCategory.medium, UIContentSizeCategory.large:
            extraLargeText = false
        default:
            extraLargeText = true
        }
        
        let minimumWidth: CGFloat
        let maxColumnCount: Int
        
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return super.collectionView(collectionView, layout: layout, minimumContentWidthForItemAt: indexPath, givenSectionWidth: sectionWidth, edgeInsets: edgeInsets)
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
                return sectionWidth
            default:
                minimumWidth = extraLargeText ? 250.0 : 180.0
                maxColumnCount = 3
            }
        }
        
        return layout.columnContentWidth(forMinimumItemContentWidth: minimumWidth, maximumColumnCount: maxColumnCount, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let title: String
        let subtitle: String
        
        let wantsMultiLineSubtitle: Bool
        switch Section(rawValue: indexPath.section)! {
        case .header:
            return super.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: itemWidth)
        case .registration:
            let regoItem = RegistrationItem(rawValue: indexPath.item)
            title    = regoItem?.localizedTitle ?? ""
            subtitle = regoItem?.value(from: nil) ?? ""
            wantsMultiLineSubtitle = false
        case .owner:
            let ownerItem = OwnerItem(rawValue: indexPath.item)
            title    = ownerItem?.localizedTitle ?? ""
            subtitle = ownerItem?.value(for: nil) ?? ""
            wantsMultiLineSubtitle = ownerItem?.wantsMultiLineDetail ?? false
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, emphasis: .subtitle, singleLineSubtitle: wantsMultiLineSubtitle == false)
    }
    
    
    // MARK: - Enums
    
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
    
}
