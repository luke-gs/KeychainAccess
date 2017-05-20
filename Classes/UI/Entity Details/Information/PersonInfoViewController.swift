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
        didSet {
            guard let person = self.person else {
                hasContent = false
                self.sections = []
                return
            }
            hasContent = true
            
            var sections: [(SectionType, [Any]?)] = [(.header, nil), (.details, [DetailItem.mni])]
            
            if let licences = person.licences {
                licences.forEach {
                    sections.append((.licence($0), LicenceItem.licenceItems(for: $0)))
                }
            }
            
            if let addresses = person.addresses, addresses.isEmpty == false {
                sections.append((.addresses, addresses)) // TODO: Sort by date
            }
            
            sections.append((.contact, ContactDetailItem.allCases))
            
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
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        noContentTitleLabel?.text = NSLocalizedString("No Person Found", bundle: .mpolKit, comment: "")
        noContentSubtitleLabel?.text = NSLocalizedString("There are no details for this person", bundle: .mpolKit, comment: "")
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EntityDetailCollectionViewCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
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
        
        func subtitleFieldCell() -> CollectionViewFormSubtitleCell {
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.emphasis = .subtitle
            cell.isEditableField = false
            cell.subtitleLabel.numberOfLines = 0
            return cell
        }
        
        let section = sections[indexPath.section]
        
        switch section.type {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: EntityDetailCollectionViewCell.self, for: indexPath)
            cell.additionalDetailsButtonActionHandler = { [weak self] (cell: EntityDetailCollectionViewCell) in
                self?.entityDetailCellDidSelectAdditionalDetails(cell)
            }
            
            /// Temp updates
            cell.thumbnailView.configure(for: person)
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
                cell.subtitleLabel.text = gender.description + " (\(NSLocalizedString("DOB unknown", bundle: .mpolKit, comment: "")))"
            } else {
                cell.subtitleLabel.text = NSLocalizedString("DOB and gender unknown", bundle: .mpolKit, comment: "")
            }
            
            cell.descriptionLabel.text = "196 cm proportionate european male with short brown hair and brown eyes"
            cell.additionalDetailsButton.setTitle(nil, for: .normal)
            
            return cell
        case .details:
            let cell = subtitleFieldCell()
            
            let item = section.items![indexPath.item] as! DetailItem
            cell.titleLabel.text = item.localizedTitle
            cell.subtitleLabel.text = item.value(for: person!)
            cell.imageView.image = nil
            return cell
        case .addresses:
            let cell = subtitleFieldCell()
            
            let item = section.items![indexPath.item] as! Address
            cell.titleLabel.text = "Recorded date unknown"
            cell.subtitleLabel.text = item.formatted()
            cell.imageView.image = UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)
            
            return cell
        case .contact:
            let cell = subtitleFieldCell()
            
            let item = section.items![indexPath.item] as! ContactDetailItem
            cell.titleLabel.text = item.localizedTitle
            cell.subtitleLabel.text = item.value(for: person!)
            cell.imageView.image = nil
            
            return cell
        default:
            return subtitleFieldCell()
        }
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
        switch sections[indexPath.section].type {
        case .contact:
            return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
        default:
            return sectionWidth
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let section = sections[indexPath.section]
        
        let wantsSingleLineSubtitle: Bool
        let title: String
        let subtitle: String
        let image: UIImage?
        
        switch section.type {
        case .header:
            return EntityDetailCollectionViewCell.minimumContentHeight(withTitle: "Smith, Max R.", subtitle: "08/05/1987 (29 Male)", description: "196 cm proportionate european male with short brown hair and brown eyes", additionalDetails: "4 MORE DESCRIPTIONS", source: "DATA SOURCE 1", inWidth: itemWidth, compatibleWith: traitCollection) - layout.itemLayoutMargins.bottom
        default:
            image = nil
            title = "Email address"
            subtitle = "john.citizen@gmail.com"
            wantsSingleLineSubtitle = false
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: .subtitle, singleLineSubtitle: wantsSingleLineSubtitle)
    }
    
    
    // MARK: - Private
    
    private enum SectionType {
        case header
        case details
        case alias
        case licence(Licence)
        case addresses
        case contact
        
        func localizedTitle(withCount count: Int? = nil) -> String {
            switch self {
            case .header:
                return NSLocalizedString("LAST UPDATED", bundle: .mpolKit, comment: "")
            case .details:
                return NSLocalizedString("DETAILS", bundle: .mpolKit, comment: "")
            case .alias:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ALIAS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ALIASES", bundle: .mpolKit, comment: ""),
                                  count ?? NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .licence(_):
                return NSLocalizedString("LICENCE", bundle: .mpolKit, comment: "")
            case .addresses:
                switch count {
                case .some(1):
                    return NSLocalizedString("1 ADDRESS", bundle: .mpolKit, comment: "")
                default:
                    return String(format: NSLocalizedString("%@ ADDRESSES", bundle: .mpolKit, comment: ""),
                                  count ?? NSLocalizedString("NO", bundle: .mpolKit, comment: ""))
                }
            case .contact:
                return NSLocalizedString("CONTACT DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private enum DetailItem {
        case mni
        
        var localizedTitle: String {
            return NSLocalizedString("MNI Number", bundle: .mpolKit, comment: "")
        }
        
        func value(for person: Person) -> String? {
            // TODO
            return "Unknown"
        }
    }
    
    private enum LicenceItem {
        case licenceClass
        case licenceType
        case number
        case validity
        
        static func licenceItems(for licence: Licence) -> [LicenceItem] {
            return [.licenceClass, .licenceType, .number, .validity]
        }
        
        var localizedTitle: String {
            switch self {
            case .licenceClass:  return NSLocalizedString("Class",          bundle: .mpolKit, comment: "")
            case .licenceType:   return NSLocalizedString("Type",           bundle: .mpolKit, comment: "")
            case .number:        return NSLocalizedString("Licence number", bundle: .mpolKit, comment: "")
            case .validity:      return NSLocalizedString("Valid until",    bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for licence: Licence) -> String? {
            // TODO: Fill these details in
            switch self {
            case .licenceClass:  return "Motor Vehicle"
            case .licenceType:   return "Open Licence"
            case .number:        return "0123456789"
            case .validity:      return "15/05/17"
            }
        }
    }
    
    private enum ContactDetailItem {
        case email
        case phone
        
        static let allCases: [ContactDetailItem] = [.email, .phone]
        
        var localizedTitle: String {
            switch self {
            case .email: return NSLocalizedString("Email Address", bundle: .mpolKit, comment: "")
            case .phone: return NSLocalizedString("Contact Number", bundle: .mpolKit, comment: "")
            }
        }
        
        func value(for person: Person) -> String? {
            switch self {
            case .email: return "john.citizen@gmail.com"
            case .phone: return "N/A"
            }
        }
        
    }
    
    
    private func entityDetailCellDidSelectAdditionalDetails(_ cell: EntityDetailCollectionViewCell) {
    }
    
    
    @objc private func entityThumbnailDidSelect(_ thumbnail: EntityThumbnailView) {
    }
    
}
