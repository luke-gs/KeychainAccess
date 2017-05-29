//
//  InterventionOrderViewController.swift
//  Pods
//
//  Created by Gridstone on 26/5/17.
//
//

import UIKit

open class InterventionOrderViewController: FormCollectionViewController {
    
    open var interventionOrder: InterventionOrder? {
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
        title = NSLocalizedString("Intervention Order", bundle: .mpolKit, comment: "")
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
            title = "Intervention Order"
            detail = "#\(interventionOrder!.id)"
            image = nil
            emphasis = .title
        default:
            guard let item = section.items?[indexPath.row] else { return cell }
            title = item.title
            detail = item.detail.ifNotEmpty() ?? "N/A"
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
        case .order:
            if indexPath.row != 0 {
                return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
            } else {
                return sectionWidth
            }
        case .respondent:
            return layout.columnContentWidth(forMinimumItemContentWidth: 250.0, maximumColumnCount: 2, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets).floored(toScale: traitCollection.currentDisplayScale)
        default:
            return sectionWidth
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        
        let section = sections[indexPath.section]
        
        switch section.type {
        case .header:
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: "Title", subtitle: "Involvement #\(interventionOrder!.id)", inWidth: itemWidth, compatibleWith: traitCollection, image: nil, emphasis: .title, singleLineSubtitle: false)
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
        guard let interventionOrder = self.interventionOrder else {
            sections = []
            return
        }
        
        let order: [FormItem] = [
            FormItem(title: "Type", detail: interventionOrder.type, image: nil),
            FormItem(title: "Served Date", detail: displayString(for: interventionOrder.servedDate), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Address", detail: interventionOrder.address, image: UIImage(named: "iconGeneralLocation", in: .mpolKit, compatibleWith: nil))
        ]
        
        let respondent: [FormItem] = [
            FormItem(title: "Respondent Name", detail: interventionOrder.respondentName, image: UIImage(named: "iconEntityPerson", in: .mpolKit, compatibleWith: nil)),
            FormItem(title: "Respondent Date of Birth", detail: displayString(for: interventionOrder.respondentDateOfBirth), image: UIImage(named: "iconFormCalendar", in: .mpolKit, compatibleWith: nil))
        ]
        
        let status: [FormItem] = [
            FormItem(title: "Status", detail: interventionOrder.status, image: nil),
            FormItem(title: "Complainants", detail: "-", image: nil),
            FormItem(title: "Conditions", detail: "-", image: nil)
        ]
        
        self.sections = [
            (.header, nil),
            (.order, order),
            (.respondent, respondent),
            (.status, status)
        ]
    }
    
    private enum SectionType: Int {
        case header
        case order
        case status
        case respondent
        
        var localizedTitle: String {
            switch self {
            case .header:           return NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "")
            case .order:            return NSLocalizedString("ORDER DETAILS", bundle: .mpolKit, comment: "")
            case .respondent:       return NSLocalizedString("RESPONDENT DETAILS", bundle: .mpolKit, comment: "")
            case .status:           return NSLocalizedString("INTERVENTION DETAILS", bundle: .mpolKit, comment: "")
            }
        }
    }
    
    // TODO: When VC has common involvement detail superclass which contains the methods below, remove this logic from this class
    private func displayString(for array: [String]?) -> String? {
        return array?.joined(separator: " ").ifNotEmpty()
    }
    
    private func displayString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateFormatter.longDateAndTime.string(from: date)
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
