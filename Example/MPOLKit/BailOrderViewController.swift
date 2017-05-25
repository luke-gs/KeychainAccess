//
//  BailOrderViewController.swift
//  MPOLKit
//
//  Created by Gridstone on 23/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MPOLKit

class BailOrderViewController: FormCollectionViewController {
    
    private var bailOrder: BailOrder?
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, y @ h:mm a"
        return formatter
    }()
    
    private var sections: [(type: SectionType, items: [FormItem]?)] = [(.header, nil)] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Initializers
    
    public override init() {
        super.init()
        title = "Involvement Detail" //NSLocalizedString("Bail Order", bundle: .mpolKit, comment: "")
    }
    
    public convenience init(bailOrder: BailOrder!) {
        self.init()
        self.bailOrder = bailOrder
        
        createFormDisplayItems()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let item = section.items?[indexPath.row]
        
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
            break
        case .reporting, .hearing, .informant, .posted:
            title = (item?.title)!
            if let itemDetail = item?.detail {
                detail = itemDetail
            } else {
                detail = "N/A"
            }
            image = item?.image
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
            let item = (section.items?[indexPath.row])!
            
            let image = item.image
            let title = item.title
            let subtitle = item.detail
            let wantsSingleLineSubtitle = false
            
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: title, subtitle: subtitle, inWidth: itemWidth, compatibleWith: traitCollection, image: image, emphasis: .subtitle, singleLineSubtitle: wantsSingleLineSubtitle)
        }
    }
    
    // MARK: - Private
    
    private func createFormDisplayItems() {
        
        var sections: [(SectionType, [FormItem]?)] = [(.header, nil)]
        
        // Reporting Requirements
        var reporting: [FormItem] = []
        reporting.append(FormItem(title: "Reporting Requirements", detail: displayString(forArray: bailOrder?.reportingRequirements), image: nil))
        reporting.append(FormItem(title: "Reporting To Station", detail: bailOrder?.reportingToStation, image: nil))
        reporting.append(FormItem(title: "Conditions", detail: displayString(forArray: bailOrder?.conditions), image: nil))
        sections.append((.reporting, reporting))
        
        // Hearing Details
        var hearing: [FormItem] = []
        hearing.append(FormItem(title: "Hearing Date", detail: displayString(forDate: bailOrder?.hearingDate), image: nil))
        hearing.append(FormItem(title: "Hearing Location", detail: bailOrder?.hearingLocation, image: nil))
        sections.append((.hearing, hearing))
        
        // Informant Details
        var informant: [FormItem] = []
        informant.append(FormItem(title: "Informant Station", detail: bailOrder?.informantStation , image: nil))
        informant.append((FormItem(title: "Informant Member", detail: bailOrder?.informantMember, image: nil)))
        sections.append((.informant, informant))
        
        // Posted Details
        var posted: [FormItem] = []
        posted.append(FormItem(title: "Posted Date", detail: displayString(forDate: bailOrder?.postedDate), image: nil))
        posted.append(FormItem(title: "Posted At", detail: bailOrder?.postedAt, image: nil))
        posted.append(FormItem(title: "Has Owner Undetaking", detail: displayString(forBool: bailOrder?.hasOwnerUndertaking), image: nil))
        posted.append(FormItem(title: "First Report Date", detail: displayString(forDate: bailOrder?.firstReportDate), image: nil))
        sections.append((.posted, posted))
        
        self.sections = sections
    }
    
    /// Iterates and appends an array of strings with a new line character. If the
    /// array is nil or its count is 0 it will return nil
    ///
    /// - Parameters:
    ///   - array:      The array of strings to append.
    /// - Returns:      The appended string or nil.
    private func displayString(forArray array: [String]?) -> String? {
        if array != nil {
            if (array!.count == 0) { return nil }
            
            return array!.joined(separator: " ")
        }
        return nil
    }
    
    /// Returns a display string for a date or nil if the date is nil
    ///
    /// - Parameters:
    ///   - date:       The date to convert to a string.
    /// - Returns:      The display string or nil.
    private func displayString(forDate date: Date?) -> String? {
        if (date != nil) {
            return BailOrderViewController.dateFormatter.string(from: date!)
        }
        return nil
    }
    
    /// Returns a "Yes" or "No" for a bool or nil if the bool is nil
    ///
    /// - Parameters:
    ///   - bool:       The bool to convert to a string.
    /// - Returns:      "Yes", "No" or nil.
    private func displayString(forBool bool: Bool?) -> String? {
        if bool != nil {
            return bool! ? "Yes" : "No"
        }
        return nil
    }
    
    private enum SectionType: Int {
        case header
        case reporting
        case hearing
        case informant
        case posted
        
        var localizedTitle: String {
            switch self {
            case .header:       return "DESCRIPTION" //return NSLocalizedString("DESCRIPTION", bundle: .mpolKit, comment: "")
            case .reporting:    return "REPORTING REQUIREMENTS" //return NSLocalizedString("REPORTING REQUIREMENTS", bundle: .mpolKit, comment: "")
            case .hearing:      return "HEARING DETAILS" //return NSLocalizedString("HEARING DETAILS", bundle: .mpolKit, comment: "")
            case .informant:    return "INFORMANT DETAILS" //return NSLocalizedString("INFORMANT DETAILS", bundle: .mpolKit, comment: "")
            case .posted:       return "POSTED DETAILS" //return NSLocalizedString("POSTED DETAILS", bundle: .mpolKit, comment: "")
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
