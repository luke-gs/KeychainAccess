//
//  EventDetailViewController.swift
//  Pods
//
//  Created by Rod Brown on 26/5/17.
//
//

import UIKit

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
        public var subtitle: String?
        public var placeholder: String?
        public var image: UIImage?
        public var preferredColumnCount: Int
        public var minimumContentWidth: CGFloat
        
        public init(style: Style = .valueField, title: String, subtitle: String?, placeholder: String? = nil, image: UIImage? = nil, preferredColumnCount: Int = 3, minimumContentWidth: CGFloat = 180.0) {
            self.style = style
            self.title = title
            self.subtitle = subtitle
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
        let cell = collectionView.dequeueReusableCell(of: CollectionViewFormSubtitleCell.self, for: indexPath)
        
        let item = sections[indexPath.section].items[indexPath.item]
        switch item.style {
        case .header:
            cell.emphasis = .title
            cell.titleLabel.font = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
        case .item:
            if cell.emphasis == .title {
                // Toggle emphasis to subtitle and then back to ensure the default font is reset.
                cell.emphasis = .subtitle
            }
            cell.emphasis = .title
        case .valueField:
            cell.emphasis = .subtitle
            cell.isEditableField = false
        }
        
        cell.titleLabel.text = item.title
        
        if let subtitle = item.subtitle?.ifNotEmpty() {
            // TODO: Handle placeholder on subtitle cell
            cell.subtitleLabel.text = subtitle
        } else {
            cell.subtitleLabel.text = item.placeholder
        }
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    // MARK: - CollectionViewDelegateFormLayout
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat {
        let section = sections[section]
        if section.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            return 0.0
        }
        return CollectionViewFormExpandingHeaderView.minimumHeight
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]
        
        var columnCount = item.preferredColumnCount
        if columnCount > 1 {
            columnCount = min(layout.columnCountForSection(withMinimumItemContentWidth: item.minimumContentWidth, sectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets), columnCount)
        }
        
        return layout.columnContentWidth(forColumnCount: columnCount, inSectionWidth: sectionWidth, sectionEdgeInsets: edgeInsets)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat {
        let item = sections[indexPath.section].items[indexPath.item]
        
        let titleFont: UIFont?
        let singleLineTitle: Bool
        
        switch item.style {
        case .header:
            titleFont = .systemFont(ofSize: 28.0, weight: UIFontWeightBold)
            singleLineTitle = false
        case .item:
            titleFont = nil
            singleLineTitle = false
        case .valueField:
            titleFont = nil
            singleLineTitle = true
        }
        // TODO: Handle placeholder on subtitle cell
        
        return CollectionViewFormSubtitleCell.minimumContentHeight(withTitle: item.title, subtitle: item.subtitle?.ifNotEmpty() ?? item.placeholder, inWidth: itemWidth, compatibleWith: traitCollection, image: item.image, emphasis: item.style == .valueField ? .subtitle : .title, titleFont: titleFont, singleLineTitle: singleLineTitle)
    }
    
}
