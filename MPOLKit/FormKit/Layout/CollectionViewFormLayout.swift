//
//  CollectionViewFormLayout.swift
//  FormKit
//
//  Created by Rod Brown on 27/04/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public let collectionElementKindGlobalHeader = "collectionElementKindGlobalHeader"
public let collectionElementKindGlobalFooter = "collectionElementKindGlobalFooter"

public let collectionElementKindSectionBackground = "sectionBackground"
public let collectionElementKindSeparatorSection  = "separatorSection"
public let collectionElementKindSeparatorRow      = "separatorRow"
public let collectionElementKindSeparatorItem     = "separatorItem"



/// The `CollectionViewFormLayout` class is a concrete layout object that organizes items into a
/// form-styled grid with optional header and footer views for each section, and optional global
/// header and footer views.
///
/// A form layout works with the collection view’s delegate to determine the size of items,
/// headers, and footers in each section. The delegate object must conform to the
/// `CollectionViewDelegateFormLayout` protocol. Use of the delegate allows you to adjust layout
/// information dynamically by invalidating the layout, and returning different sizes.
///
/// Form layouts lay out their content according to the set `distribution` property, and sizes
/// content based on the minimum content size the element can support. First, if supported, the
/// delegate returns the minimum size for the section, and then for each item in the section, its
/// minimum content width is requested, including headers and footers. For items, the delegate
/// should only return the size of the content within the layout margins. The form layout is
/// responsible for applying any appropriate insets. The form layout uses these content values
/// to calculate how many sections can fit horizontally next to each other, and how many items
/// can fit in each row. Any additional width in each row is apportioned to the items
/// on the basis of the `distribution` setting.
///
/// Form layouts request item minimum heights after the content width of each item is calculated.
/// The delegate is asked the minimum content height for the cell given the content width, and all
/// cells in the row are given the height of the largest item in the row.
open class CollectionViewFormLayout: UICollectionViewLayout {
    
    // This is the default standard separator color for iOS 7 - 10.
    fileprivate static let separatorGray = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
    
    
    // MARK: - Associated enums
    
    @objc(CollectionViewFormLayoutDistribution) public enum Distribution: Int {
        /// The default for the collection view
        case automatic
        
        /// Apportions additional space equally between the items in a row
        case fillEqually
        
        /// Apportions additional space to the last item in a row
        case fillLast
        
        /// Cells will not be distributed excess space in rows.
        case none
    }
    
    
    // MARK: - Public properties
    
    public let style: CollectionViewFormStyle
    
    /// The layout margins for items within the collection.
    ///
    /// The form layout uses these layout margins, together with section insets, to calculate the correct
    /// layout margins for each item.
    ///
    /// Cells should report minimum sizes based on sizes within their layout margins, and lay out their contents appropriately.
    ///
    /// Cells used with `CollectionViewFormLayout` should also override `applyLayoutMargins(_:)` to detect
    /// instances of `CollectionViewFormLayoutItemAttributes` and apply the contained `layoutMargins` property.
    ///
    /// - seealso: `CollectionViewFormItemAttributes.layoutMargins`
    open var itemLayoutMargins: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 8.0, right: 10.0) {
        didSet {
            let screenScale = (collectionView?.window?.screen ?? UIScreen.main).scale
            let setMargins = itemLayoutMargins
            let newMargins = UIEdgeInsets(top: setMargins.top.floored(toScale: screenScale), left: setMargins.left.floored(toScale: screenScale), bottom: setMargins.bottom.floored(toScale: screenScale), right: setMargins.right.floored(toScale: screenScale))
            if newMargins != setMargins { self.itemLayoutMargins = newMargins }
            if newMargins != oldValue   { invalidateLayout() }
        }
    }
    
    
    /// The color of section backgrounds in the collection view.
    ///
    /// Section colors can be used to create an appearance similar to UITableView.
    /// The default is `nil`.
    open var sectionColor: UIColor? {
        didSet {
            let sectionColor = self.sectionColor
            let sectionBackgroundAttributes = style.sectionBackgroundAttributes
            if sectionColor == oldValue || sectionBackgroundAttributes.isEmpty { return }
            
            let indexPaths: [IndexPath] = sectionBackgroundAttributes.map { $0.backgroundColor = sectionColor; return $0.indexPath }
            let invalidationContext = UICollectionViewLayoutInvalidationContext()
            invalidationContext.invalidateDecorationElements(ofKind: collectionElementKindSectionBackground, at: indexPaths)
            invalidateLayout(with: invalidationContext)
        }
    }
    
    
    /// The color of item separators in the collection view.
    ///
    /// The default color is a standard separator gray.
    open var itemSeparatorColor: UIColor? = CollectionViewFormLayout.separatorGray {
        didSet {
            let separatorColor = self.itemSeparatorColor
            let sectionRects = style.sectionRects
            if separatorColor == oldValue || sectionRects.count == 0 { return }
            
            var rowSeparators: [IndexPath] = []
            var rowCapacity = 0
            for section in style.rowSeparatorAttributes {
                rowCapacity += section.count
                if rowCapacity > 0 { rowSeparators.reserveCapacity(rowCapacity) }
                for row in section {
                    row.backgroundColor = separatorColor
                    rowSeparators.append(row.indexPath)
                }
            }
            
            var itemSeparators: [IndexPath] = []
            var itemCapacity = 0
            for section in style.itemSeparatorAttributes {
                itemCapacity += section.count
                if rowCapacity > 0 { rowSeparators.reserveCapacity(rowCapacity) }
                for item in section {
                    item.backgroundColor = separatorColor
                    itemSeparators.append(item.indexPath)
                }
            }
            
            let invalidationContext = UICollectionViewLayoutInvalidationContext()
            var invalidate = false
            if rowSeparators.isEmpty == false {
                invalidate = true
                invalidationContext.invalidateDecorationElements(ofKind: collectionElementKindSeparatorRow, at: rowSeparators)
            }
            if itemSeparators.isEmpty == false {
                invalidate = true
                invalidationContext.invalidateDecorationElements(ofKind: collectionElementKindSeparatorItem, at: itemSeparators)
            }
            if invalidate {
                invalidateLayout(with: invalidationContext)
            }
            
        }
    }
    /// The color of section separators in the collection view.
    ///
    /// The default color is a standard separator gray.
    open var sectionSeparatorColor: UIColor? = CollectionViewFormLayout.separatorGray {
        didSet {
            let sectionSeparatorColor = self.sectionSeparatorColor
            let sectionSeparatorAttributes = style.sectionSeparatorAttributes
            
            var sectionSeparators: [IndexPath] = []
            sectionSeparators.reserveCapacity(sectionSeparatorAttributes.count * 3)
            for section in sectionSeparatorAttributes {
                for separator in section {
                    separator.backgroundColor = sectionSeparatorColor
                    sectionSeparators.append(separator.indexPath)
                }
            }
            
            if sectionSeparators.isEmpty == false {
                let invalidationContext = UICollectionViewLayoutInvalidationContext()
                invalidationContext.invalidateDecorationElements(ofKind: collectionElementKindSeparatorSection, at: sectionSeparators)
                invalidateLayout(with: invalidationContext)
            }
        }
    }
    
    /// The width for the item separators. The default is 1 pixel on the collection view's current screen.
    open var separatorWidth: CGFloat {
        get {
            if let separator = _separatorWidth { return separator }
            let screen = collectionView?.window?.screen ?? UIScreen.main
            return 1.0 / screen.scale }
        set {
            let newWidth = max(0.0, newValue)
            if newWidth == _separatorWidth { return }
            _separatorWidth = newWidth
            invalidateLayout()
        }
    }
    
    
    /// The distribution method to use for cell sizing. The default is `CollectionViewFormLayout.Distribution.fillEqually`.
    open var distribution: CollectionViewFormLayout.Distribution = .fillEqually {
        didSet {
            if distribution == .automatic {
                distribution = .fillEqually
            }
            
            if distribution != oldValue {
                invalidateLayout()
            }
        }
    }
    
    
    // MARK: - Private properties
    
    fileprivate var _separatorWidth: CGFloat?
    fileprivate var _lastLaidOutWidth: CGFloat?
    
    fileprivate var previousSectionRowSeparatorCounts: [Int] = []
    fileprivate var previousSectionItemCounts:         [Int] = []
    fileprivate var previousSectionSeparatorCounts:    [Int] = []
    
    
    // MARK: - Initialization
    
    public init(style: CollectionViewFormStyle) {
        self.style = style
        super.init()
        style.formLayout = self
        
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSectionBackground)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorSection)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorRow)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorItem)
    }
    
    
    /// CollectionViewFormLayout does not support NSCoding.
    public required init?(coder aDecoder: NSCoder) {
        fatalError("CollectionViewFormLayout does not support NSCoding.")
    }
    
    
    
    // MARK: - Layout preparation
    
    open override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        
        previousSectionRowSeparatorCounts = style.rowSeparatorAttributes.map { $0.count }
        previousSectionItemCounts         = style.itemSeparatorAttributes.map { $0.count }
        previousSectionSeparatorCounts    = style.sectionSeparatorAttributes.map { $0.count }
        
        _lastLaidOutWidth = collectionView.bounds.width
        
        if collectionView != style.collectionView {
            style.collectionView = collectionView
        }
        style.prepare()
    }
    
    // MARK: - Layout attribute fetching
    
    open override var collectionViewContentSize : CGSize {
        return style.contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if let globalHeaderAttribute = style.globalHeaderAttribute,
            globalHeaderAttribute.frame.intersects(rect) {
            attributes.append(globalHeaderAttribute)
        }
        if let globalFooterAttribute = style.globalFooterAttribute,
            globalFooterAttribute.frame.intersects(rect) {
            attributes.append(globalFooterAttribute)
        }
        
        for (sectionIndex, sectionRect) in style.sectionRects.enumerated() {
            if sectionRect.minY > rect.maxY { break }
            if sectionRect.intersects(rect) == false { continue }
            
            if let sectionHeaderItem = style.sectionHeaderAttributes[sectionIndex]
                , sectionHeaderItem.frame.intersects(rect) {
                attributes.append(sectionHeaderItem)
            }
            
            let sectionBackgroundItem  = style.sectionBackgroundAttributes[sectionIndex]
            let sectionBackgroundFrame = sectionBackgroundItem.frame
            if sectionBackgroundFrame.minY > rect.maxY { break }
            
            if let sectionSeparators = style.sectionSeparatorAttributes[ifExists: sectionIndex] {
                for separator in sectionSeparators where separator.frame.intersects(rect) {
                    attributes.append(separator)
                }
            }
            
            if sectionBackgroundFrame.intersects(rect) {
                attributes.append(sectionBackgroundItem)
                
                let itemSeparators = style.itemSeparatorAttributes[ifExists: sectionIndex]
                for (itemIndex, item) in style.itemAttributes[sectionIndex].enumerated() {
                    let frame = item.frame
                    if frame.minY > rect.maxY { break }
                    if frame.intersects(rect) {
                        attributes.append(item)
                        if let itemSeparator = itemSeparators?[ifExists: itemIndex] {
                            attributes.append(itemSeparator)
                        }
                    }
                }
                
                if let rowSeparators = style.rowSeparatorAttributes[ifExists: sectionIndex] {
                    for row in rowSeparators where row.frame.intersects(rect) {
                        attributes.append(row)
                    }
                }
            }
            
            if let sectionFooterItem = style.sectionFooterAttributes[sectionIndex] , sectionFooterItem.frame.intersects(rect) {
                attributes.append(sectionFooterItem)
            }
        }
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return style.itemAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            if let item = style.sectionHeaderAttributes[ifExists: indexPath.section] { return item }
        case UICollectionElementKindSectionFooter:
            if let item = style.sectionFooterAttributes[ifExists: indexPath.section] { return item }
        case collectionElementKindGlobalHeader:
            if let header = style.globalHeaderAttribute, indexPath == header.indexPath { return header }
        case collectionElementKindGlobalFooter:
            if let footer = style.globalFooterAttribute, indexPath == footer.indexPath { return footer }
        default:
            break
        }
        
        return nil
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: CollectionViewFormDecorationAttributes?
        
        switch elementKind {
        case collectionElementKindSectionBackground: attributes = style.sectionBackgroundAttributes[ifExists: indexPath.section]
        case collectionElementKindSeparatorSection:  attributes = style.sectionSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        case collectionElementKindSeparatorRow:      attributes = style.rowSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        case collectionElementKindSeparatorItem:     attributes = style.itemSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        default:                                     attributes = nil
        }
        
        return attributes ?? CollectionViewFormDecorationAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
    }
    
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = self.collectionView,
            style.shouldInvalidateLayout(forBoundsChange: newBounds) else { return false }
        
        let currentContentWidth = fabs(_lastLaidOutWidth ?? 0.0)
        let newWidth = fabs(newBounds.size.width)
//        
//        // Don't perform an update if there is no width, or if there is no content.
//        if newWidth == currentContentWidth || (sectionRects.last?.maxY.isZero ?? true) { return false }

        if UIView.areAnimationsEnabled {
            let animationDuration = UIView.inheritedAnimationDuration
            if animationDuration.isZero { return true }
            
            DispatchQueue.main.async {
                var firstCellIndexPath: IndexPath? = nil
                
                if let attributes = self.layoutAttributesForElements(in: collectionView.bounds) {
                    for attribute in attributes {
                        if attribute.representedElementCategory != .cell { continue }
                        firstCellIndexPath = attribute.indexPath
                        break
                    }
                }
                
                self.invalidateLayout()
                
                if let firstIP = firstCellIndexPath {                    
                    collectionView.scrollToItem(at: firstIP, at: UICollectionViewScrollPosition(), animated: false)
                }
                
                UIView.transition(with: collectionView, duration: animationDuration, options: [.transitionCrossDissolve, .layoutSubviews, (newWidth > currentContentWidth ? .curveEaseOut : .curveEaseIn)], animations: nil)
            }
            return false
        } else {
            return true
        }
    }
    
    
    // MARK: - Updates
    
    fileprivate var insertedItemSeparators: [IndexPath]?
    fileprivate var deletedItemSeparators:  [IndexPath]?
    fileprivate var insertedRowSeparators:  [IndexPath]?
    fileprivate var deletedRowSeparators:   [IndexPath]?
    fileprivate var insertedSections: [Int]?
    fileprivate var deletedSections:  [Int]?
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = self.collectionView else { return }
        
        insertedItemSeparators = []
        deletedItemSeparators  = []
        
        insertedSections = []
        deletedSections  = []
        
        for item in updateItems {
            if (item.indexPathBeforeUpdate ?? item.indexPathAfterUpdate)?.row == NSIntegerMax {
                // Section updates
                switch item.updateAction {
                case .insert:
                    let section = item.indexPathAfterUpdate!.section
                    insertedSections!.append(section)
                    insertedItemSeparators! += (0..<collectionView.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .delete:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedSections!.append(section)
                    deletedItemSeparators! += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                case .reload:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedItemSeparators! += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                    insertedItemSeparators! += (0..<collectionView.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .move:
                    let oldSection = item.indexPathBeforeUpdate!.section
                    deletedSections!.append(oldSection)
                    deletedItemSeparators! += (0..<previousSectionItemCounts[oldSection]).map { IndexPath(item: $0, section: oldSection) }
                    let newSection = item.indexPathAfterUpdate!.section
                    insertedSections!.append(newSection)
                    insertedItemSeparators! += (0..<collectionView.numberOfItems(inSection: newSection)).map { IndexPath(item: $0, section: newSection) }
                case .none:
                    break
                }
            } else {
                // Item update
                switch item.updateAction {
                case .insert:
                    insertedItemSeparators!.append(item.indexPathAfterUpdate!)
                case .delete:
                    deletedItemSeparators!.append(item.indexPathBeforeUpdate!)
                case .move:
                    deletedItemSeparators!.append(item.indexPathBeforeUpdate!)
                    insertedItemSeparators!.append(item.indexPathAfterUpdate!)
                default:
                    break
                }
            }
        }
        
        insertedRowSeparators = []
        deletedRowSeparators = []
        
        for (index, section) in style.rowSeparatorAttributes.enumerated() {
            var newCount = section.count
            var oldCount = previousSectionRowSeparatorCounts[ifExists: index] ?? 0
            
            if newCount != oldCount {
                while newCount > oldCount {
                    insertedRowSeparators!.append(IndexPath(item:newCount - 1, section: index))
                    newCount -= 1
                }
                while oldCount > newCount {
                    deletedRowSeparators!.append(IndexPath(item:oldCount - 1, section: index))
                    oldCount -= 1
                }
            }
        }
    }
    
    open override func finalizeCollectionViewUpdates() {
        insertedItemSeparators = nil
        deletedItemSeparators  = nil
        insertedRowSeparators  = nil
        deletedRowSeparators   = nil
        insertedSections       = nil
        deletedSections        = nil
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        attributes?.alpha = 0.0
        return attributes
    }
    
    open override func indexPathsToInsertForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        switch elementKind {
        case collectionElementKindSeparatorItem:
            return insertedItemSeparators ?? []
        case collectionElementKindSeparatorRow:
            return insertedRowSeparators ?? []
        case collectionElementKindSectionBackground:
            return insertedSections?.map({ IndexPath(item: 0, section: $0) }) ?? []
        case collectionElementKindSeparatorSection:
            var allSectionSeparators: [IndexPath] = []
            insertedSections?.forEach {
                if let sectionSeparatorIndexPaths: [IndexPath] = style.sectionSeparatorAttributes[ifExists: $0]?.flatMap({ $0.indexPath }) {
                    allSectionSeparators += sectionSeparatorIndexPaths
                }
            }
            return allSectionSeparators
        default:
            return []
        }
    }
    
    open override func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        switch elementKind {
        case collectionElementKindSeparatorItem:
            return deletedItemSeparators ?? []
        case collectionElementKindSeparatorRow:
            return deletedRowSeparators ?? []
        case collectionElementKindSectionBackground:
            return deletedSections?.map({ IndexPath(item: 0, section: $0) }) ?? []
        case collectionElementKindSeparatorSection:
            var allSectionSeparators: [IndexPath] = []
            deletedSections?.forEach { (section: Int) in
                if let previousSectionCount = previousSectionSeparatorCounts[ifExists: section], previousSectionCount > 0 {
                    allSectionSeparators += (0..<previousSectionCount).map { IndexPath(item: $0, section: section) }
                }
            }
            return allSectionSeparators
        default:
            return []
        }
    }
}


@objc public protocol CollectionViewDelegateFormLayout: UICollectionViewDelegate {
    
    /// Asks the delegate for the height of the global header view. If you do not implement this method,
    /// the layout defaults to having no global header view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    /// - Returns:          The height of the header. If you return 0.0, no header is added.
    @objc optional func collectionView(_ collectionView: UICollectionView, heightForGlobalHeaderInLayout layout: CollectionViewFormLayout) -> CGFloat
    
    
    /// Asks the delegate for the height of the global footer view. If you do not implement this method,
    /// the layout defaults to having no global footer view.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    /// - Returns:          The height of the footer. If you return 0.0, no footer is added.
    @objc optional func collectionView(_ collectionView: UICollectionView, heightForGlobalFooterInLayout layout: CollectionViewFormLayout) -> CGFloat
    
    
    /// Asks the delegate for the minimum width for the section. If you do not implement this method,
    /// the section defaults to the collection view's full width.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose minimum width is being requested.
    /// - Returns:          The minimum width for the section.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumWidthForSection section: Int) -> CGFloat
    
    
    /// Asks the delegate for the distribution method for the section. If you do not implement this method,
    /// the layout defaults to the global `distribution` property.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose minimum width is being requested.
    /// - Returns:          The minimum width for the section.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, distributionForSection section: Int) -> CollectionViewFormLayout.Distribution
    
    
    /// Asks the delegate for the height of the specified section header.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose header size is being requested.
    ///   - width:          The width for the section.
    /// - Returns:          The height of the header. If you return a value of 0.0, no header is added.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat
    
    
    /// Asks the delegate for the height of the specified section footer.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose footer size is being requested.
    ///   - width:          The width for the section.
    /// - Returns:          The height of the footer. If you return a value of 0.0, no footer is added.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int, givenSectionWidth width: CGFloat) -> CGFloat
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose insets are being requested.
    ///   - width:          The width for the section.
    /// - Returns:          The margins to apply to items in the section.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int, givenSectionWidth width: CGFloat) -> UIEdgeInsets
    
    
    /// Asks the delegate for the minimum width for the item, given the maximum width of the section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    ///   - sectionWidth:   The width for the section.
    ///   - edgeInsets:     The insets for the section.
    /// - Returns:          The minimum required width for the item.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, givenSectionWidth sectionWidth: CGFloat, edgeInsets: UIEdgeInsets) -> CGFloat
    
    
    /// Asks the delegate for the minimum height for the item, given the width allocated to it.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    ///   - itemWidth:      The width for the item.
    /// - Returns:          The minimum required height for the item.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenItemContentWidth itemWidth: CGFloat) -> CGFloat
}


public extension CollectionViewFormLayout {
    
    /// A convenience function for calculating content widths for cells in column formation.
    ///
    /// - Parameters:
    ///   - columnCount:         The number of columns in the section.
    ///   - sectionWidth:        The contentWidth of the section.
    ///   - sectionEdgeInsets:   The edge insets for the section.
    ///   - minimumContentWidth: The minimum width for the column. The default value is `0.0`.
    /// - Returns:               The content width for a single item in the specified column layout. When a minumumColumnWidth
    ///                          is specified, returns the correct width to spread the item between multiple columns.
    public func itemContentWidth(forEqualColumnCount columnCount: Int, givenSectionWidth sectionWidth: CGFloat, edgeInsets sectionEdgeInsets: UIEdgeInsets, minimumContentWidth: CGFloat = 0.0) -> CGFloat {
        precondition(columnCount > 0, "columnCount must be more than zero.")
        
        let itemLayoutMargins    = self.itemLayoutMargins
        let leadingSectionInset  = ceil(sectionEdgeInsets.left.isZero  ? itemLayoutMargins.left  : sectionEdgeInsets.left)
        let trailingSectionInset = ceil(sectionEdgeInsets.right.isZero ? itemLayoutMargins.right : sectionEdgeInsets.right)
        
        if columnCount == 1 { return sectionWidth - leadingSectionInset - trailingSectionInset}
        
        let columnCountFloat = CGFloat(columnCount)
        
        let adjustmentValue = ((columnCountFloat - 1.0) * (itemLayoutMargins.left + itemLayoutMargins.right)) + leadingSectionInset + trailingSectionInset
        let singleItemSize = max(sectionWidth - adjustmentValue, 0.0) / columnCountFloat
         
        var itemSize = singleItemSize
        let scale = collectionView?.window?.screen.scale ?? 1.0
        while itemSize < minimumContentWidth {
            itemSize += itemLayoutMargins.left + itemLayoutMargins.right + singleItemSize.floored(toScale: scale)
        }
        
        return itemSize
    }
}


/********** Convenience functions **********/

private extension Array {
    /// Access the `index`th element, if it exists. Complexity: O(1).
    subscript (ifExists index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
