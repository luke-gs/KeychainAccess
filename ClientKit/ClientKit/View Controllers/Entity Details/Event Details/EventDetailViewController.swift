//
//  EventDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import UIKit
import MPOLKit

open class EventDetailViewController: FormCollectionViewController {
    
    // MARK: - Related types
    
    
    /// Represents a section within an `EventDetailViewController`.
    public struct EventDetailSection {
        public var title: String?
        public var items: [EventDetailItem]
    }
    
    
    /// Represents an item within an `EventDetailViewController`.
    public struct EventDetailItem {
        public enum Style {
            case header
            case item
            case valueField
        }
        
        public var style: Style
        public var title: String?
        public var detail: String?
        public var placeholder: String?
        public var image: UIImage?
        public var preferredColumnCount: Int
        public var minimumContentWidth: CGFloat
        
        public init(style: Style = .valueField, title: String?, detail: String?, placeholder: String? = nil, image: UIImage? = nil, preferredColumnCount: Int = 3, minimumContentWidth: CGFloat = 180.0) {
            self.style = style
            self.title = title?.ifNotEmpty()
            self.detail = detail?.ifNotEmpty()
            self.placeholder = placeholder
            self.image = image
            self.preferredColumnCount = preferredColumnCount
            self.minimumContentWidth = minimumContentWidth
        }
    }
    
    
    // MARK: - Public properties
    
    /// The event to display. The default is `nil`.
    open var event: Event? {
        didSet {
            updateSections()
        }
    }
    
    
    /// The current sections for the collection to present.
    ///
    /// Subclasses should set this property to update the section on
    /// display. Setting this property automatically updates the collection
    /// view, if loaded.
    open var sections: [EventDetailSection] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: - Public methods
    
    /// Updates the sections propety for the current event.
    ///
    /// Subclasses should override this method to update the sections
    /// property appropriately for their event type. This method is called
    /// each time the event is set. The default is a nop.
    open func updateSections() {
    }
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.register(CollectionViewFormSubtitleCell.self)
        collectionView.register(CollectionViewFormValueFieldCell.self)
        collectionView.register(CollectionViewFormExpandingHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, class: CollectionViewFormExpandingHeaderView.self, for: indexPath)
            view.showsExpandArrow = false
            view.text = sections[indexPath.section].title
            
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.item]
        switch item.style {
        case .header:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.detail
            return cell
        case .item:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.font = .preferredFont(forTextStyle: .headline)
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.detail
            return cell
        case .valueField:
            let cell = collectionView.dequeueReusableCell(of: CollectionViewFormValueFieldCell.self, for: indexPath)
            cell.imageView.image = item.image
            cell.isEditable = false
            cell.titleLabel.text = item.title
            cell.valueLabel.text = item.detail
            cell.placeholderLabel.text = item.placeholder
            return cell
        }
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        if section.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            return 0.0
        }
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]
        
        var columnCount = item.preferredColumnCount
        if columnCount > 1 {
            columnCount = min(layout.columnCountForSection(withMinimumItemContentWidth: item.minimumContentWidth, sectionEdgeInsets: sectionEdgeInsets), columnCount)
        }
        
        return layout.columnContentWidth(forColumnCount: columnCount, sectionEdgeInsets: sectionEdgeInsets)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]
        
        
        switch item.style {
        case .header, .item:
            let titleFont: UIFont? = item.style == .header ? .systemFont(ofSize: 28.0, weight: UIFontWeightBold) : nil
            let titleSizing = StringSizing(string: item.title ?? "", font: titleFont, numberOfLines: 0)
            return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: titleSizing, subtitle: item.detail?.ifNotEmpty(), inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero) + (item.style == .header ? 15.0 : 0.0)
        case .valueField:
            return CollectionViewFormValueFieldCell.minimumContentHeight(withTitle: item.title, value: item.detail ?? item.placeholder, inWidth: itemWidth, compatibleWith: traitCollection, imageSize: item.image?.size ?? .zero)
        }
    }
    
}
