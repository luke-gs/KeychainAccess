//
//  PersonInfoViewController.swift
//  MPOL
//
//  Created by Rod Brown on 17/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

open class PersonInfoViewController: EntityDetailCollectionViewController {
    
    open override var entity: Entity? {
        get { return person }
        set { self.person = newValue as? Person }
    }
    
    private var person: Person? {
        didSet {
            guard let person = self.person else {
                hasContent = false
                self.sections = []
                return
            }
            hasContent = true
            
            var sections: [(SectionType, [Any]?)] = [(.header, nil), (.details, [DetailItem.mni, DetailItem.ethnicity])]
            
            if let licences = person.licences {
                licences.forEach {
                    sections.append((.licence($0), LicenceItem.licenceItems(for: $0)))
                }
            }
            
            if let aliases = person.aliases, aliases.isEmpty == false {
                sections.append((.aliases, aliases))
            }
            
            if let addresses = person.addresses, addresses.isEmpty == false {
                sections.append((.addresses, addresses)) // TODO: Sort by date
            }
            
            var contactDetails: [ContactDetailItem] = []
//            if let emails = person.emails {
//                emails.forEach {
//                    contactDetails.append(.email($0))
//                }
//            }
            if let phones = person.phoneNumbers {
                phones.forEach {
                    contactDetails.append(.phone($0))
                }
            }
            if contactDetails.count > 0 {
                sections.append((.contact, contactDetails))
            }
            
            self.sections = sections
        }
    }
    
    private var sections: [(type: SectionType, items: [Any]?)] = [(.header, nil)] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Information", bundle: .mpolKit, comment: "")
        
        let sidebarItem = self.sidebarItem
        sidebarItem.image         = UIImage(named: "iconGeneralInfo",       in: .mpolKit, compatibleWith: nil)
        sidebarItem.selectedImage = UIImage(named: "iconGeneralInfoFilled", in: .mpolKit, compatibleWith: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("PersonInfoViewController does not support NSCoding.")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Person Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("There are no details for this person", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormProgressCell.self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items?.count ?? 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            
            let section = sections[indexPath.section]
            
            switch section.type {
            case .header:
                let lastUpdatedString: String
                if let lastUpdated = person?.lastUpdated {
                    lastUpdatedString = DateFormatter.shortDate.string(from: lastUpdated)
                } else {
                    lastUpdatedString = NSLocalizedString("UNKNOWN", bundle: .mpolKit, comment: "Unknown Date")
                }
                headerView.text = NSLocalizedString("LAST UPDATED: ", bundle: .mpolKit, comment: "") + lastUpdatedString
            default:
                headerView.text = section.type.localizedTitle(withCount: section.items?.count)
            }
            
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        
        let title: String
        let value: String?
        let image: UIImage?
        
        switch section.type {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            cell.thumbnailView.configure(for: person, size: .large)
            cell.thumbnailView.imageView.image = #imageLiteral(resourceName: "Avatar 1")
// TODO
//            if cell.thumbnailView.allTargets.contains(self) == false {
//                cell.thumbnailView.isEnabled = true
//                cell.thumbnailView.addTarget(self, action: #selector(entityThumbnailDidSelect(_:)), for: .primaryActionTriggered)
//            }
            
            cell.sourceLabel.text = person?.source?.localizedBadgeTitle
            cell.titleLabel.text = person?.summary
            cell.subtitleLabel.text = person?.summaryDetail1
            
            if let descriptions = person?.descriptions, let firstDescription = descriptions.first {
                cell.descriptionLabel.text = firstDescription.formatted()
                cell.isDescriptionPlaceholder = false
                
                if descriptions.count > 1 {
                    let moreDescriptionsCount = descriptions.count - 1
                    let buttonTitle = "\(moreDescriptionsCount) MORE DESCRIPTION\(moreDescriptionsCount > 1 ? "S" : "")"
                    cell.additionalDetailsButton.setTitle(buttonTitle, for: .normal)
                } else {
                    cell.additionalDetailsButton.setTitle(nil, for: .normal)
                }
            } else {
                cell.descriptionLabel.text = NSLocalizedString("No description", bundle: .mpolKit, comment: "")
                cell.isDescriptionPlaceholder = true
                
                cell.additionalDetailsButton.setTitle(nil, for: .normal)
            }
            
            return cell
        case .details:
            let item = section.items![indexPath.item] as! DetailItem
            title = item.localizedTitle
            value = item.value(for: person!)
            image = nil
        case .addresses:
            let item = section.items![indexPath.item] as! Address
            
            if let date = item.reportDate {
                title = String(format: NSLocalizedString("%@ - Recorded as at %@", bundle: .mpolKit, comment: ""), item.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
            } else {
                title = String(format:NSLocalizedString("%@ - Recorded date unknown", bundle: .mpolKit, comment: ""),  item.type ?? "Unknown")
            }
            
            value = item.formatted()
            image = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
        case .contact:
            let item = section.items![indexPath.item] as! ContactDetailItem
            title = item.localizedTitle
            value = item.value?.ifNotEmpty() ?? "N/A"
            image = item.image
        case .aliases:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            let alias = section.items![indexPath.item] as! Alias
            cell.titleLabel.text = alias.formattedName
            cell.subtitleLabel.text = alias.formattedDOBAgeGender()
            cell.subtitleLabel.numberOfLines = 1
            cell.imageView.image = nil
            return cell
        case .licence(let licence):
            let item = section.items![indexPath.item] as! LicenceItem
            
            title  = item.localizedTitle
            value = item.value(for: licence)
            image  = nil
            
            if item == .validity {
                let progressCell = collectionView.dequeueReusableCell(of: CollectionViewFormProgressCell.self, for: indexPath)
                progressCell.imageView.image = image
                progressCell.titleLabel.text = title
                progressCell.valueLabel.text = value
                progressCell.isEditable = false
                
                if let startDate = licence.effectiveFromDate, let endDate = licence.effectiveToDate {
                    progressCell.progressView.isHidden = false
                    
                    let timeIntervalBetween = endDate.timeIntervalSince(startDate)
                    let timeIntervalToNow   = startDate.timeIntervalSinceNow * -1.0
                    let progress = Float(timeIntervalToNow / timeIntervalBetween)
                    progressCell.progressView.progress = progress
                    progressCell.progressView.progressTintColor = progress > 1.0 ? #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1) : #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1)
                } else {
                    progressCell.progressView.isHidden = true
                }
                
                return progressCell
            }
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
        cell.isEditable = false
        
        cell.titleLabel.text  = title
        cell.valueLabel.text = value
        cell.imageView.image  = image?.withRenderingMode(.alwaysTemplate)
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let detailCell = cell as? EntityDetailCollectionViewCell {
            detailCell.titleLabel.textColor       = primaryTextColor   ?? .black
            detailCell.subtitleLabel.textColor    = secondaryTextColor ?? .darkGray
            detailCell.descriptionLabel.textColor = detailCell.isDescriptionPlaceholder ? placeholderTextColor ?? .lightGray : secondaryTextColor ?? .darkGray
        }
        
        if let subtitleCell = cell as? CollectionViewFormSubtitleCell {
            subtitleCell.titleLabel.textColor = secondaryTextColor
        }
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        return CollectionViewFormHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        switch sections[indexPath.section].type {
        case .contact:
            return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionEdgeInsets: sectionEdgeInsets).floored(toScale: traitCollection.currentDisplayScale)
        case .licence(_):
            let item = sections[indexPath.section].items![indexPath.item] as! LicenceItem
            
            let columnCount = max(min(layout.columnCountForSection(withMinimumItemContentWidth: 180.0, sectionEdgeInsets: sectionEdgeInsets), 3), 1)
            return layout.itemContentWidth(fillingColumns: item == .validity ? 2 : 1, inSectionWithColumns: columnCount, sectionEdgeInsets: sectionEdgeInsets)
        default:
            return collectionView.bounds.width
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let section = sections[indexPath.section]
        
        let wantsSingleLineValue: Bool
        let title: String
        let value: String?
        let image: UIImage?
        
        switch section.type {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: person?.summary ?? "", subtitle: person?.summaryDetail1, description: person?.descriptions?.first?.formatted(), descriptionPlaceholder: NSLocalizedString("No description", bundle: .mpolKit, comment: ""), additionalDetails: person?.descriptions != nil && person!.descriptions!.count > 1 ? "X MORE DESCRIPTIONS" : nil, source: person?.source?.localizedBadgeTitle, inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        case .details:
            let item = section.items![indexPath.item] as! DetailItem
            title = item.localizedTitle
            value = item.value(for: person!)
            image = nil
            wantsSingleLineValue = false
        case .addresses:
            let item = section.items![indexPath.item] as! Address
            
            if let date = item.reportDate {
                title = String(format: NSLocalizedString("%@ Recorded as at %@", bundle: .mpolKit, comment: ""), item.type ?? "Unknown", DateFormatter.mediumNumericDate.string(from: date))
            } else {
                title = String(format: NSLocalizedString("%@ Recorded date unknown", bundle: .mpolKit, comment: ""), item.type ?? "Unknown")
            }
            
            value = item.formatted()
            image = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
            wantsSingleLineValue = false
        case .contact:
            let item = section.items![indexPath.item] as! ContactDetailItem
            title = item.localizedTitle
            value = item.value?.ifNotEmpty() ?? "N/A"
            image = item.image
            wantsSingleLineValue = true
        case .aliases:
            let alias = section.items![indexPath.item] as! Alias
            title = alias.formattedName ?? ""
            value = alias.formattedDOBAgeGender()
            image = nil
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: value, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero)
        case .licence(let licence):
            let item = section.items![indexPath.item] as! LicenceItem
            
            title  = item.localizedTitle
            value = item.value(for: licence)
            image  = nil
            wantsSingleLineValue = true
        }
        
        let valueSizing = StringSizing(string: value ?? "", numberOfLines: wantsSingleLineValue ? 1 : 0)
        return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: title, value: valueSizing, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: image?.size ?? .zero)
    }
    
    
    // MARK: - Private
    
    private enum SectionType {
        case header
        case details
        case aliases
        case licence(Licence)
        case addresses
        case contact
        
        func localizedTitle(withCount count: Int? = nil) -> String {
            switch self {
            case .header:
                return NSLocalizedString("LAST UPDATED", bundle: .mpolKit, comment: "")
            case .details:
                return NSLocalizedString("DETAILS", bundle: .mpolKit, comment: "")
            case .aliases:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ALIAS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ALIASES", bundle: .mpolKit, comment: ""),
                                  count != nil ? String(describing: count!) : NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .licence(_):
                return NSLocalizedString("LICENCE", bundle: .mpolKit, comment: "")
            case .addresses:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ADDRESS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ADDRESSES", bundle: .mpolKit, comment: ""),
                                  count != nil ? String(describing: count!) : NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .contact:
                return NSLocalizedString("CONTACT DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private enum DetailItem {
        case mni
        case ethnicity
        
        var localizedTitle: String {
            switch self {
            case .mni:
                return NSLocalizedString("MNI Number", bundle: .mpolKit, comment: "")
            case .ethnicity:
                return NSLocalizedString("Ethnicity", bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for person: Person) -> String? {
            switch self {
            case .mni:
                return person.id
            case .ethnicity:
                return person.ethnicity ?? "N/A"
            }
        }
    }
    
    private enum LicenceItem: Int {
        case number
        case state
        case country
        case status
        case validity
        
        static func licenceItems(for licence: Licence) -> [LicenceItem] {
            return [.number, .state, .country, .status, .validity]
        }
        
        var localizedTitle: String {
            switch self {
            case .number:        return NSLocalizedString("Licence number", bundle: .mpolKit, comment: "")
            case .state:         return NSLocalizedString("State",          bundle: .mpolKit, comment: "")
            case .country:       return NSLocalizedString("Country",        bundle: .mpolKit, comment: "")
            case .status:        return NSLocalizedString("Status",         bundle: .mpolKit, comment: "")
            case .validity:      return NSLocalizedString("Valid until",    bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for licence: Licence) -> String? {
            // TODO: Fill these details in
            switch self {
            case .number:
                return licence.number
            case .state:
                return licence.state
            case .country:
                return licence.country
            case .status:
                return licence.status
            case .validity:
                if let effectiveDate = licence.effectiveToDate {
                    return DateFormatter.mediumNumericDate.string(from: effectiveDate)
                } else {
                    return NSLocalizedString("Expiry date unknown", bundle: .mpolKit, comment: "")
                }
            }
        }
    }
    
    private enum ContactDetailItem {
        case email(Email)
        case phone(PhoneNumber)
        
        var localizedTitle: String {
            switch self {
            case .email(_): return NSLocalizedString("Email Address", bundle: .mpolKit, comment: "")
            case .phone(let phone): return NSLocalizedString(phone.formattedType(), bundle: .mpolKit, comment: "")
            }
        }
        
        var value: String? {
            switch self {
            case .email(_): return "john.citizen@gmail.com"
            case .phone(let phone): return phone.formattedNumber()
            }
        }
        
        var image: UIImage? {
            switch self {
            case .email(_): return UIImage(named: "iconFormEmail", in: .mpolKit, compatibleWith: nil)
            case .phone(_): return UIImage(named: "iconFormPhone", in: .mpolKit, compatibleWith: nil)
            }
        }
    }
    
    
    @objc private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
        guard let navController = pushableSplitViewController?.navigationController ?? navigationController else { return }
        let moreDescriptionsVC = PersonDescriptionsViewController()
        moreDescriptionsVC.descriptions = person!.descriptions
        navController.pushViewController(moreDescriptionsVC, animated: true)
    }
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
    }
    
}

fileprivate extension Alias {
    
    func formattedDOBAgeGender() -> String? {
        if let dob = dateOfBirth {
            let yearComponent = Calendar.current.dateComponents([.year], from: dob, to: Date())
            
            var dobString = DateFormatter.mediumNumericDate.string(from: dob) + " (\(yearComponent.year!)"
            
            if let gender = sex?.localizedCapitalized {
                dobString += " \(gender))"
            } else {
                dobString += ")"
            }
            return dobString
        } else if let gender = sex?.localizedCapitalized, gender.isEmpty == false {
            return gender + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
        } else {
            return NSLocalizedString("DOB and gender unknown", bundle: .mpolKit, comment: "")
        }
    }
}
