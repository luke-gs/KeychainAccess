//
//  BailOrderViewController.swift
//  MPOLKit
//
//  Created by Gridstone on 23/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

open class BailOrderViewController: FormCollectionViewController {
    
    open var bailOrder: BailOrder? {
        didSet {
            updateSections()
        }
    }
    
    private var sections: [(type: SectionType, items: [FormItem]?)] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = NSLocalizedString("Bail Order", bundle: .mpolKit, comment: "")
    }
    
    // MARK: - View lifecycle
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(CollectionViewFormSubtitleCell.self)
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
            
            let sectionType = sections[indexPath.section].type
            headerView.text = sectionType.localizedTitle
            
            return headerView
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        
        let title: String
        let detail: String?
        let image: UIImage?
        let emphasis: CollectionViewFormSubtitleCell.Emphasis

        switch section.type {
        case .header:
            title = "Bail Order"
            detail = "Involvement #\(bailOrder!.id)"
            image = nil
            emphasis = .title
        default:
            guard let item = section.items?[indexPath.row] else { return cell }
            title = item.title
            detail = item.detail ?? "N/A"
            image = item.image
            emphasis = .subtitle
        }
        
        cell.isEditableField = false
        cell.subtitleLabel.numberOfLines = 0
        
        cell.titleLabel.text    = title
        cell.subtitleLabel.text = detail
        cell.imageView.image    = image
        cell.emphasis           = emphasis
        
        return cell
    }
    
    // MARK: - CollectionViewDelegateMPOLLayout

    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        switch sections[indexPath.section].type {
        case .hearing, .informant, .posted:
            return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
        default:
            return sectionWidth
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let section = sections[indexPath.section]
        
        switch section.type {
        case .header:
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Title", subtitle: "Id", inWidth: itemWidth, compatibleWith: traitCollection, image: nil, emphasis: .title, singleLineSubtitle: false)
        default:
            let item = section.items![indexPath.row]
            
            let image = item.image
            let title = item.title
            let subtitle = item.detail
            let wantsSingleLineSubtitle = false
            
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: .subtitle, singleLineSubtitle: wantsSingleLineSubtitle)
        }
    }
    
    // MARK: - Private
    
    private func updateSections() {
        guard let bailOrder = self.bailOrder else {
            sections = []
            return
        }
        
        // Reporting Requirements
        let reporting: [FormItem] = [
            FormItem(title: "Reporting Requirements", detail: displayString(for: bailOrder.reportingRequirements), image: nil),
            FormItem(title: "Reporting To Station", detail: bailOrder.reportingToStation, image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Conditions", detail: displayString(for: bailOrder.conditions), image: nil)
        ]
        
        // Hearing Details
        let hearing: [FormItem] = [
            FormItem(title: "Hearing Date", detail: displayString(for: bailOrder.hearingDate), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Hearing Location", detail: bailOrder.hearingLocation, image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil))
        ]
        
        // Informant Details
        let informant: [FormItem] = [
            FormItem(title: "Informant Station", detail: bailOrder.informantStation , image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Informant Member", detail: bailOrder.informantMember, image: UIImage(named: "iconEntityPerson", in: .mpolKit, compatibleWith: nil))
        ]
        
        // Posted Details
        let posted: [FormItem] = [
            FormItem(title: "Posted Date", detail: displayString(for: bailOrder.postedDate), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Posted At", detail: bailOrder.postedAt, image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Has Owner Undetaking", detail: displayString(for: bailOrder.hasOwnerUndertaking), image: nil),
            FormItem(title: "First Report Date", detail: displayString(for: bailOrder.firstReportDate), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil))
        ]
        
        self.sections = [
            (.header, nil),
            (.reporting, reporting),
            (.hearing, hearing),
            (.informant, informant),
            (.posted, posted)
        ]
    }
    
    private func displayString(for array: [String]?) -> String? {
        return array?.joined(separator: " ").ifNotEmpty()
    }
    
    private func displayString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateFormatter.longDateAndTime.string(from: date)
    }
    
    private func displayString(for bool: Bool?) -> String? {
        guard let bool = bool else { return nil }
        return bool ? "Yes" : "No"
    }
    
    private enum SectionType: Int {
        case header
        case reporting
        case hearing
        case informant
        case posted
        
        var localizedTitle: String {
            switch self {
            case .header:       return NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "")
            case .reporting:    return NSLocalizedString("REPORTING REQUIREMENTS", bundle: .mpolKit, comment: "")
            case .hearing:      return NSLocalizedString("HEARING DETAILS", bundle: .mpolKit, comment: "")
            case .informant:    return NSLocalizedString("INFORMANT DETAILS", bundle: .mpolKit, comment: "")
            case .posted:       return NSLocalizedString("POSTED DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    private struct FormItem {
        var title: String
        var detail: String?
        var image: UIImage?
        
        init(title: String, detail: String?, image: UIImage?) {
            self.title = title
            self.detail = detail
            self.image = image
        }
    }
}
