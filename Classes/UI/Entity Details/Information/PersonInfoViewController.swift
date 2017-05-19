//
//  PersonInfoViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class PersonInfoViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet { collectionView?.reloadData() }
    }
    
    
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
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormProgressCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:    return 1
        case .licences:  return LicenceItem.count
        case .addresses: return 2
        case .contact:   return 1
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            
            let section = indexPath.section
            
            if section == 0 {
                let lastUpdatedString: String
                if let lastUpdated = person?.lastUpdated {
                    lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
                } else {
                    lastUpdatedString = NSLocalizedString("UNKNOWN", comment: "Unknown Date")
                }
                headerView.text = NSLocalizedString("LAST UPDATED: ", comment: "") + lastUpdatedString
            } else {
                headerView.text = Section(rawValue: section)?.localizedTitle
            }
            
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = Section(rawValue: indexPath.section)!
        
        if section == .header {
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            /// Temp updates
            cell.thumbnailView.configure(for: NSObject())
            if cell.thumbnailView.allTargets.contains(self) == false {
                cell.thumbnailView.isEnabled = true
                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
            }
            
            cell.sourceLabel.text = person?.source?.localizedUppercase
            cell.titleLabel.text = person?.summary
            
            if let dob = person?.dateOfBirth {
                let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
                
                var dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
                
                if let gender = person?.gender {
                    dobString += " \(gender.description))"
                } else {
                    dobString += ")"
                }
                cell.subtitleLabel.text = dobString
            } else if let gender = person?.gender {
                cell.subtitleLabel.text = gender.description + " (\(NSLocalizedString("DOB unknown", comment: "")))"
            } else {
                cell.subtitleLabel.text = NSLocalizedString("DOB and gender unknown", comment: "")
            }
            
            cell.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            cell.additionalDetailsButton.setTitle(nil, for: .normal)
            
            return cell
        }
        
        
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
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = secondaryTextColor ?? .darkGray
        }
    }
    
    
    // MARK: - CollectionViewDelegateMPOLLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
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
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
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
    
    
    // MARK: - Private
    
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
    
    
    private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
    }
    
}
