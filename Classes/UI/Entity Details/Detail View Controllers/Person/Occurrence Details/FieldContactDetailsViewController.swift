//
//  FieldContactDetailsViewController.swift
//  Pods
//
//  Created by Rod Brown on 25/5/17.
//
//

import UIKit

open class FieldContactDetailsViewController: FormCollectionViewController {
    
    // MARK: - Public properties
    
    open var fieldContact: FieldContact? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Initializers
    
    public init(fieldContact: FieldContact? = nil) {
        super.init()
        
        title = NSLocalizedString("Field Contact", comment: "Form Title")
        self.fieldContact = fieldContact
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(EventDetailHeaderCell.self)
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count(for: fieldContact)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .description:
            return DescriptionItem.count
        case .place:
            return PlaceItem.count
        case .contactDescriptions:
            return fieldContact?.contactDescriptions?.count ?? 0
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            headerView.showsExpandArrow = false
            headerView.text = Section(rawValue: indexPath.section)!.localizedTitle
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let title: String
        let detail: String?
        let image: UIImage?
        let emphasis: CollectionViewFormSubtitleCell.Emphasis
        
        switch Section(rawValue: indexPath.section)! {
        case .description:
            let descriptionItem = DescriptionItem(rawValue: indexPath.item)!
            
            title    = descriptionItem.localizedTitle
            detail   = descriptionItem.value(for: fieldContact)
            image    = descriptionItem.image
            
            if descriptionItem == .title {
                let headerCell = collectionView.dequeueReusableCell(of: EventDetailHeaderCell.self, for: indexPath)
                headerCell.imageView.image = image
                headerCell.titleLabel.text = title
                headerCell.subtitleLabel.text = detail
                return headerCell
            }
            
            emphasis = .subtitle
        case .place:
            let placeItem = PlaceItem(rawValue: indexPath.item)!
            title  = placeItem.localizedTitle
            detail = placeItem.value(for: fieldContact)
            image  = placeItem.image
            emphasis = .subtitle
        case .contactDescriptions:
            let appropriateText = self.appropriateText(forContactDescriptionAt: indexPath.item)
            title = appropriateText.title
            detail = appropriateText.subtitle
            image = nil
            emphasis = .subtitle
        }
        
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 0
        
        cell.titleLabel.text    = title
        cell.subtitleLabel.text = detail
        cell.imageView.image    = image
        cell.emphasis           = emphasis
        
        return cell
        
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        let maxColumnCount: Int
        switch Section(rawValue: indexPath.section)! {
        case .description:
            maxColumnCount = DescriptionItem(rawValue: indexPath.item)!.preferredMaxColumnCount
        case .place:
            maxColumnCount = PlaceItem(rawValue: indexPath.item)!.preferredMaxColumnCount
        case .contactDescriptions:
            return sectionWidth
        }
        
        if maxColumnCount <= 1 {
            return sectionWidth
        }
        
        return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: maxColumnCount, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let title: String
        let detail: String?
        let image: UIImage?
        let emphasis: CollectionViewFormSubtitleCell.Emphasis
        
        switch Section(rawValue: indexPath.section)! {
        case .description:
            let descriptionItem = DescriptionItem(rawValue: indexPath.item)!
            
            title    = descriptionItem.localizedTitle
            detail   = descriptionItem.value(for: fieldContact)
            image    = descriptionItem.image
            
            if descriptionItem == .title {
                return EventDetailHeaderCell.minimumContentHeight(withTitle: title, subtitle: detail, inWidth: itemWidth, compatibleWith: traitCollection)
                
            }
            
            emphasis = .subtitle
        case .place:
            let placeItem = PlaceItem(rawValue: indexPath.item)!
            title  = placeItem.localizedTitle
            detail = placeItem.value(for: fieldContact)
            image  = placeItem.image
            emphasis = .subtitle
        case .contactDescriptions:
            let appropriateText = self.appropriateText(forContactDescriptionAt: indexPath.item)
            title = appropriateText.title
            detail = appropriateText.subtitle
            image = nil
            emphasis = .subtitle
        }
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: detail, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: emphasis)
    }
    
    
    // MARK: - Private
    
    private enum Section: Int {
        case description
        case place
        case contactDescriptions
        
        static func count(for fieldContact: FieldContact?) -> Int {
            return fieldContact?.contactDescriptions?.isEmpty ?? true ? 2 : 3
        }
        
        var localizedTitle: String? {
            switch self {
            case .description: return NSLocalizedString("DESCRIPTION", comment: "Field contact section")
            case .place:       return NSLocalizedString("PLACE", comment: "Field contact section")
            case .contactDescriptions: return NSLocalizedString("CONTACT DESCRIPTIONS", comment: "Field contact section")
            }
        }
    }
    
    private enum DescriptionItem: Int {
        case title
        case dateAndTime
        case status
        case primaryMember
        case secondaryMember
        case reportingStation
        
        static let count = 6
        
        var localizedTitle: String {
            switch self {
            case .title:            return NSLocalizedString("Field Contact", comment: "Form Title")
            case .dateAndTime:      return NSLocalizedString("Occurred on",   comment: "Date/time event occurred")
            case .status:           return NSLocalizedString("Status",        comment: "Field Contact status")
            case .primaryMember:    return NSLocalizedString("Contact Member Rank", comment: "") // TODO: Rank? Why not name?
            case .secondaryMember:  return NSLocalizedString("Secondary Contact Member Rank", comment: "") // TODO: Rank? Why not name?
            case .reportingStation: return NSLocalizedString("Reporting Station",   comment: "")
            }
        }
        
        func value(for fieldContact: FieldContact?) -> String? {
            switch self {
            case .title:
                // TODO: fix
                if let id = fieldContact?.id {
                    return "Involvement #" + id
                } else {
                    return NSLocalizedString("Involvement number unknown", comment: "")
                }
            case .dateAndTime:
                if let date = fieldContact?.contactDate {
                    return DateFormatter.longDateAndTime.string(from: date)
                } else {
                    return NSLocalizedString("Unknown", comment: "Unknown date and time")
                }
            case .status:
                return fieldContact?.status
            case .primaryMember:
                return fieldContact?.contactMember?.rank ?? NSLocalizedString("Unknown", comment: "Unknown Member") // TODO: Rank? Why not name?
            case .secondaryMember:
                return fieldContact?.secondaryContactMember?.rank ?? NSLocalizedString("Unknown", comment: "Unknown Member") // TODO: Rank? Why not name?
            case .reportingStation:
                return fieldContact?.reportingStation
            }
        }
        
        var image: UIImage? {
            return self == .dateAndTime ? UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil) : nil
        }
        
        var preferredMaxColumnCount: Int {
            switch self {
            case .title:
                return 1
            case .dateAndTime, .status:
                return 2
            default:
                return 3
            }
        }
    }
    
    private enum PlaceItem: Int {
        case location
        case areaType
        case locationResponseZone
        case neighbourhoodWatchArea
        case localGovernmentArea
        
        static let count = 5
        
        var localizedTitle: String {
            switch self {
            case .location:  return NSLocalizedString("Location", comment: "Contact location")
            case .areaType:  return NSLocalizedString("Area Type", comment: "Field Contact area")
            case .locationResponseZone:   return NSLocalizedString("Location Response Zone", comment: "Field Contact area")
            case .neighbourhoodWatchArea: return NSLocalizedString("Neighbourhood Watch Area", comment: "Field Contact area")
            case .localGovernmentArea: return NSLocalizedString("Local Government area", comment: "Field Contact area")
            }
        }
        
        func value(for fieldContact: FieldContact?) -> String? {
            switch self {
            case .location: return fieldContact?.contactLocation
            case .areaType: return fieldContact?.areaType
            case .locationResponseZone:   return fieldContact?.locationResponseZone
            case .neighbourhoodWatchArea: return fieldContact?.neighbourhoodWatchArea
            case .localGovernmentArea:    return fieldContact?.localGovernmentArea
            }
        }
        
        var image: UIImage? {
            return self == .location ? UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil) : nil
        }
        
        var preferredMaxColumnCount: Int {
            switch self {
            case .location, .areaType:
                return 2
            default:
                return 3
            }
        }
    }
    
    private func appropriateText(forContactDescriptionAt index: Int) -> (title: String, subtitle: String) {
        let title = String(format: NSLocalizedString("Contact Description %d", comment: ""), index + 1)
        let subtitle = fieldContact?.contactDescriptions?[index].ifNotEmpty() ?? "-"
        return (title, subtitle)
    }
    
}
