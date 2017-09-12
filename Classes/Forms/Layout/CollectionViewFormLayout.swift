//
//  CollectionViewFormLayout.swift
//  MPOLKit
//
//  Created by Rod Brown on 27/04/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit

public let collectionElementKindGlobalHeader = "collectionElementKindGlobalHeader"
public let collectionElementKindGlobalFooter = "collectionElementKindGlobalFooter"


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
    
    // MARK: - Associated types
    
    @objc(CollectionViewFormLayoutDistribution) public enum Distribution: Int {
        /// The default for the collection view
        case automatic
        
        /// Apportions additional space equally between the items in a row
        case fillEqually
        
        /// Apportions additional space to the last item in a row
        case fillLast
        
        /// Apportions additional space to the last item in the row, when the item is
        /// within a distance of the trailing edge where another item of the same
        /// size would no longer fit. Otherwise, no distribution will occur.
        case fillLastWithinColumnDistance
        
        /// Cells will not be distributed excess space in rows.
        case none
    }
    
    private struct ElementPosition {
        var frame: CGRect
        var zIndex: Int
        var layoutMargins: UIEdgeInsets
    }
    
    private struct ItemPosition {
        var frame: CGRect
        var zIndex: Int
        var layoutMargins: UIEdgeInsets
        var rowIndex: Int
        var rowItemCount: Int
        var isAtTrailingEdge: Bool
    }
    
    
    // MARK: - Public properties
    
    open override class var layoutAttributesClass: Swift.AnyClass {
        return CollectionViewFormLayoutAttributes.self
    }
    
    /// The layout margins for items within the collection.
    ///
    /// The form layout uses these layout margins, together with section insets, to calculate the correct
    /// layout margins for each item.
    ///
    /// Cells should report minimum sizes based on sizes within their layout margins, and lay out their contents appropriately.
    ///
    /// Cells used with `CollectionViewFormLayout` should also override `applyLayoutMargins(_:)` to detect
    /// instances of `CollectionViewFormAttributes` and apply the contained `layoutMargins` property.
    ///
    /// - seealso: `CollectionViewFormAttributes.layoutMargins`
    open var itemLayoutMargins: UIEdgeInsets = UIEdgeInsets(top: 16.0, left: 12.0, bottom: 15.0, right: 12.0) {
        didSet {
            let screenScale = (collectionView?.window?.screen ?? UIScreen.main).scale
            let setMargins = itemLayoutMargins
            let newMargins = UIEdgeInsets(top: setMargins.top.floored(toScale: screenScale), left: setMargins.left.floored(toScale: screenScale), bottom: setMargins.bottom.floored(toScale: screenScale), right: setMargins.right.floored(toScale: screenScale))
            if newMargins != setMargins { self.itemLayoutMargins = newMargins }
            if newMargins != oldValue   { invalidateLayout() }
        }
    }
    
    open var wantsInsetHeaders: Bool = true {
        didSet {
            if wantsInsetHeaders != oldValue {
                invalidateLayout()
            }
        }
    }
    
    
    /// Pins the global header, if it exists, to the visible space when bounce
    /// interactions occur.
    ///
    /// This avoids showing potentially undesirable empty content above the header.
    open var pinsGlobalHeaderWhenBouncing: Bool = false {
        didSet {
            if pinsGlobalHeaderWhenBouncing != oldValue && globalHeaderPosition != nil,
                let collectionView = self.collectionView {
                updateGlobalHeaderAttributeIfNeeded(forBounds: collectionView.bounds)
            }
        }
    }
    
    
    /// The distribution method to use for cell sizing. The default is `.fillLastWithinColumnDistance`.
    open var distribution: CollectionViewFormLayout.Distribution = .fillLastWithinColumnDistance {
        didSet {
            if distribution == .automatic {
                distribution = .fillLastWithinColumnDistance
            }
            
            if distribution != oldValue {
                invalidateLayout()
            }
        }
    }
    
    
    // MARK: - Private properties
    
    private var contentSize: CGSize = .zero
    private var sectionRects: [CGRect] = []
    
    private var globalHeaderPosition: ElementPosition?
    private var globalFooterPosition: ElementPosition?
    
    private var sectionHeaderPositions: [ElementPosition?] = []
    private var sectionFooterPositions: [ElementPosition?] = []
    
    private var itemPositions: [[ItemPosition]] = []
    
    
    // MARK: - Layout preparation
    
    open override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else { return }
        
        let collectionViewBounds = collectionView.bounds
        self.contentSize = CGSize(width: collectionViewBounds.width, height: 0.0)
        let isRTL = collectionView.effectiveUserInterfaceLayoutDirection == .rightToLeft
        let screenScale = (collectionView.window?.screen ?? .main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        
        sectionRects.removeAll(keepingCapacity: true)
        sectionHeaderPositions.removeAll(keepingCapacity: true)
        sectionFooterPositions.removeAll(keepingCapacity: true)
        itemPositions.removeAll(keepingCapacity: true)
        
        let sectionCount = collectionView.numberOfSections
        sectionRects.reserveCapacity(sectionCount)
        sectionHeaderPositions.reserveCapacity(sectionCount)
        sectionFooterPositions.reserveCapacity(sectionCount)
        itemPositions.reserveCapacity(sectionCount)
        
        let itemLayoutMargins = self.itemLayoutMargins
        
        let widthForItem = delegate.collectionView(_:layout:minimumContentWidthForItemAt:sectionEdgeInsets:)
        let heightForValidation = delegate.collectionView(_:layout:heightForValidationAccessoryAt:givenContentWidth:)
        let insetForSection = delegate.collectionView(_:layout:insetForSection:)
        let heightForHeader = delegate.collectionView(_:layout:heightForHeaderInSection:)
        let heightForFooter = delegate.collectionView(_:layout:heightForFooterInSection:)
        
        // function to process a section's items. ensure that insets are accounted for.
        func processItemsInSection(_ section: Int, yOrigin: CGFloat, sectionInsets: UIEdgeInsets) -> CGFloat { // Returns height of section items
            
            let sectionDistribution: CollectionViewFormLayout.Distribution
            if let foundDistribution = delegate.collectionView?(collectionView, layout: self, distributionForSection: section) , foundDistribution != .automatic {
                sectionDistribution = foundDistribution
            } else {
                sectionDistribution = self.distribution
            }
            
            var currentYOrigin = yOrigin
            
            let sectionLeftInset  = sectionInsets.left.rounded(toScale: screenScale)
            let sectionRightInset = sectionInsets.right.rounded(toScale: screenScale)
            
            let firstItemLeftWidthInset = sectionLeftInset.isZero  ? itemLayoutMargins.left  : 0.0
            let lastItemRightWidthInset = sectionRightInset.isZero ? itemLayoutMargins.right : 0.0
            
            let sectionWidth: CGFloat = collectionViewBounds.width - sectionLeftInset - sectionRightInset
            
            let maximumAllowedWidth: CGFloat = sectionWidth - firstItemLeftWidthInset - lastItemRightWidthInset
            
            let sectionItemCount = collectionView.numberOfItems(inSection: section)
            
            var itemMinWidths: [(IndexPath, CGFloat)]
            if let widthForItem = widthForItem {
                itemMinWidths = (0..<sectionItemCount).map {
                    let indexPath = IndexPath(item: $0, section: section)
                    let width = max(min(widthForItem(collectionView, self, indexPath, sectionInsets).floored(toScale: screenScale), maximumAllowedWidth), 0.0)
                    return (indexPath, width)
                }
            } else {
                itemMinWidths = (0..<sectionItemCount).map { (IndexPath(item: $0, section: section), maximumAllowedWidth) }
            }
            
            var sectionItemPositions: [ItemPosition] = []
            sectionItemPositions.reserveCapacity(sectionItemCount)
            
            let sectionItemStartY = currentYOrigin
            if sectionItemCount > 0 {
                
                var currentItemIndex = 0
                currentYOrigin += max(0.0, round(sectionInsets.top))
                
                var rowCount = 0
                func processRow() {
                    var items: [(IndexPath, CGFloat)]
                    var rowItemCount = 0
                    var minRowContentWidths: CGFloat = 0.0
                    if widthForItem == nil {
                        items = [(itemMinWidths[currentItemIndex].0, maximumAllowedWidth)]
                        currentItemIndex += 1
                        rowItemCount = 1
                        minRowContentWidths = maximumAllowedWidth
                    } else {
                        items = []
                        var minRowWidth: CGFloat = 0.0
                        
                        while currentItemIndex < sectionItemCount {
                            let item = itemMinWidths[currentItemIndex]
                            
                            let newMinRowWidth: CGFloat
                            if rowItemCount == 0 {
                                newMinRowWidth = (item.1 + firstItemLeftWidthInset).floored(toScale: screenScale)
                            } else {
                                newMinRowWidth = (minRowWidth + itemLayoutMargins.left + itemLayoutMargins.right + item.1).floored(toScale: screenScale)
                            }
                            if (newMinRowWidth + lastItemRightWidthInset) > ceil(sectionWidth) && items.isEmpty == false { break }
                            
                            items.append(item)
                            minRowWidth = newMinRowWidth
                            minRowContentWidths += item.1
                            rowItemCount += 1
                            currentItemIndex += 1
                        }
                    }
                    
                    if rowItemCount > 0 {
                        // We've now got all items in the section. Work out how much extra space we have.
                        
                        let rowItemCountFloat = CGFloat(rowItemCount)
                        let insetSpace = (rowItemCountFloat - 1.0) * (itemLayoutMargins.left + itemLayoutMargins.right) + firstItemLeftWidthInset + lastItemRightWidthInset
                        
                        let leftOverSpace = max(sectionWidth - insetSpace - minRowContentWidths, 0.0)
                        let extraSpacePerItem    = sectionDistribution == .fillEqually ? (leftOverSpace / rowItemCountFloat).floored(toScale: screenScale) : 0.0
                        var extraAllocationWidth = sectionDistribution == .fillEqually ? (leftOverSpace * screenScale).truncatingRemainder(dividingBy: rowItemCountFloat) / screenScale : 0.0
                        
                        var minHeight: CGFloat = 0.0
                        var currentXValue: CGFloat = 0.0
                        
                        let rowItems: [(ip: IndexPath, frame: CGRect, margins: UIEdgeInsets)] = items.enumerated().map { (index: Int, element: (indexPath: IndexPath, contentWidth: CGFloat)) in
                            let indexPath = element.indexPath
                            var newContentWidth = element.contentWidth + extraSpacePerItem
                            if extraAllocationWidth > 0.0 {
                                newContentWidth += singlePixel
                                extraAllocationWidth -= singlePixel
                            }
                            
                            if leftOverSpace > 0.0 && index == rowItemCount - 1 {
                                if sectionDistribution == .fillLast {
                                    newContentWidth += leftOverSpace
                                } else if sectionDistribution == .fillLastWithinColumnDistance {
                                    let columnWidth = newContentWidth + itemLayoutMargins.left + itemLayoutMargins.right
                                    if columnWidth > leftOverSpace {
                                        // we can't fit in an extra column - fill it in.
                                        newContentWidth += leftOverSpace
                                    }
                                }
                            }
                            
                            let itemMinHeight = ceil(delegate.collectionView(collectionView, layout: self, minimumContentHeightForItemAt: indexPath, givenContentWidth: newContentWidth))
                            if minHeight < itemMinHeight { minHeight = itemMinHeight }
                            
                            if rowItemCount == 1 {
                                var insets = UIEdgeInsets(top: itemLayoutMargins.top, left: sectionLeftInset.isZero ? itemLayoutMargins.left : sectionLeftInset, bottom: itemLayoutMargins.bottom, right: sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
                                
                                let proposedEndOfContent = currentXValue + newContentWidth + insets.left
                                let endOfMaxContent      = collectionViewBounds.width - (sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
                                if proposedEndOfContent > endOfMaxContent {
                                    let difference = proposedEndOfContent - endOfMaxContent
                                    insets.right -= difference
                                }
                                return (indexPath, CGRect(x: currentXValue, y: currentYOrigin, width: newContentWidth + insets.left + insets.right, height: 0.0), insets)
                            }
                            
                            let itemInsets: UIEdgeInsets
                            if index == 0 {
                                itemInsets = UIEdgeInsets(top: itemLayoutMargins.top, left: sectionLeftInset.isZero ? itemLayoutMargins.left : sectionLeftInset, bottom: itemLayoutMargins.bottom, right: itemLayoutMargins.right)
                            } else if index == rowItemCount - 1 {
                                var insets = UIEdgeInsets(top: itemLayoutMargins.top, left: itemLayoutMargins.left, bottom: itemLayoutMargins.bottom, right: sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
                                let proposedEndOfContent = currentXValue + newContentWidth + insets.left
                                let endOfMaxContent      = collectionViewBounds.width - (sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
                                if proposedEndOfContent > endOfMaxContent {
                                    let difference = proposedEndOfContent - endOfMaxContent
                                    insets.right += difference
                                }
                                itemInsets = insets
                            } else {
                                itemInsets = itemLayoutMargins
                            }
                            
                            let frame = CGRect(x: currentXValue, y:currentYOrigin, width: newContentWidth + itemInsets.left + itemInsets.right, height: 0.0)
                            currentXValue = frame.maxX
                            
                            return (indexPath, frame, itemInsets)
                        }
                        
                        minHeight += itemLayoutMargins.top + itemLayoutMargins.bottom
                        
                        
                        var validityIndicatorHeight: CGFloat = 0.0
                        
                        for (index, item) in rowItems.enumerated() {
                            var frame = item.frame
                            frame.size.height = minHeight
                            if isRTL {
                                frame = frame.rtlFlipped(forWidth: collectionViewBounds.width)
                            }
                            let layoutMargins = isRTL ? item.margins.horizontallyFlipped() : item.margins
                            
                            let itemPosition = ItemPosition(frame: frame, zIndex: 1,  layoutMargins: layoutMargins, rowIndex: index, rowItemCount: rowItemCount, isAtTrailingEdge: fabs(frame.maxX - collectionViewBounds.width) < 0.5)
                            
                            sectionItemPositions.append(itemPosition)
                            
                            if let height = heightForValidation?(collectionView, self, item.ip, item.frame.insetBy(item.margins).width),
                                height >~ 0.0 {
                                validityIndicatorHeight = max(validityIndicatorHeight, height)
                            }
                        }
                        
                        currentYOrigin += minHeight + validityIndicatorHeight
                    }
                    
                    rowCount += 1
                }
                
                // Process the rows from the minWidth
                while currentItemIndex < sectionItemCount {
                    processRow()
                }
            }
            
            itemPositions.append(sectionItemPositions)
            
            return currentYOrigin + max(0.0, round(sectionInsets.bottom)) - yOrigin
        }
        
        var currentYOffset: CGFloat = 0.0
        
        if let globalHeaderHeight = delegate.collectionView?(collectionView, heightForGlobalHeaderInLayout: self) , globalHeaderHeight > 0.0 {
            let headerOriginY: CGFloat
            if pinsGlobalHeaderWhenBouncing {
                headerOriginY = min(currentYOffset, collectionViewBounds.minY + collectionView.contentInset.top)
            } else {
                headerOriginY = currentYOffset
            }
            
            let frame = CGRect(x: 0.0, y: headerOriginY, width: collectionViewBounds.width, height: ceil(globalHeaderHeight))
            globalHeaderPosition = ElementPosition(frame: frame, zIndex: 1, layoutMargins: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0))
            currentYOffset += ceil(globalHeaderHeight)
        } else {
            globalHeaderPosition = nil
        }
        
        let defaultWantsSectionHeaderInsets = wantsInsetHeaders
        
        for section in 0..<sectionCount {
            let sectionInset = insetForSection?(collectionView, self, section) ?? .zero
            currentYOffset += sectionInset.top
            let startOfHeader = currentYOffset
            var insetHeader = false
            
            if var headerHeight = heightForHeader?(collectionView, self, section),
                headerHeight >~ 0.0 {
                headerHeight = headerHeight.ceiled(toScale: screenScale)
                var headerLayoutMargins = UIEdgeInsets(top: 0.0, left: isRTL ? sectionInset.right : sectionInset.left, bottom: 0.0, right: isRTL ? sectionInset.left : sectionInset.right)
                var headerRect = CGRect(x: 0.0, y: currentYOffset, width: collectionViewBounds.width, height: headerHeight)
                currentYOffset += headerHeight
                
                insetHeader = delegate.collectionView?(collectionView, layout: self, shouldInsetHeaderInSection: section) ?? defaultWantsSectionHeaderInsets
                if insetHeader {
                    headerRect.size.height += itemLayoutMargins.top
                    headerLayoutMargins.bottom = itemLayoutMargins.bottom
                }
                sectionHeaderPositions.append(ElementPosition(frame: headerRect, zIndex: 10, layoutMargins: headerLayoutMargins))
            } else {
                sectionHeaderPositions.append(nil)
            }
            
            let startOfItems = currentYOffset
            
            let sectionHeight = processItemsInSection(section, yOrigin: startOfItems, sectionInsets: sectionInset)
            if sectionHeight < itemLayoutMargins.top {
                currentYOffset += itemLayoutMargins.top
            } else {
                currentYOffset += sectionHeight
            }
            
            if var footerHeight = heightForFooter?(collectionView, self, section),
                footerHeight >~ 0.0 {
                footerHeight = footerHeight.ceiled(toScale: screenScale)
                let footerFrame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewBounds.width, height: footerHeight)
                let footerLayoutMargins = UIEdgeInsets(top: 8.0, left: isRTL ? sectionInset.right : sectionInset.left, bottom: 8.0, right: isRTL ? sectionInset.left : sectionInset.right)
                sectionFooterPositions.append(ElementPosition(frame: footerFrame, zIndex: 1, layoutMargins: footerLayoutMargins))
                currentYOffset += footerHeight
            } else {
                sectionFooterPositions.append(nil)
            }
            sectionRects.append(CGRect(x: 0.0, y: startOfHeader, width: collectionViewBounds.width, height: currentYOffset - startOfHeader))
            
            currentYOffset += sectionInset.bottom
        }
        
        if let globalFooterHeight = delegate.collectionView?(collectionView, heightForGlobalFooterInLayout: self) , globalFooterHeight > 0.0 {
            let frame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewBounds.width, height: ceil(globalFooterHeight))
            globalFooterPosition = ElementPosition(frame: frame, zIndex: 1, layoutMargins: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0))
            currentYOffset += ceil(globalFooterHeight)
        } else {
            globalFooterPosition = nil
        }
        
        contentSize.height = currentYOffset
    }
    
    private func updateGlobalHeaderAttributeIfNeeded(forBounds bounds: CGRect) {
        guard let globalHeaderFrame = globalHeaderPosition?.frame else { return }
        
        let correctYOrigin: CGFloat
        if pinsGlobalHeaderWhenBouncing, let collectionView = self.collectionView {
            correctYOrigin = min(0.0, bounds.minY + collectionView.contentInset.top)
        } else {
            correctYOrigin = 0.0
        }
        
        if globalHeaderFrame.minY ==~ correctYOrigin { return }
        self.globalHeaderPosition?.frame.origin.y = correctYOrigin
            
        let context = UICollectionViewLayoutInvalidationContext()
        context.invalidateSupplementaryElements(ofKind: collectionElementKindGlobalHeader, at: [IndexPath(item: 0, section: 0)])
        invalidateLayout(with: context)
    }
    
    
    // MARK: - Layout attribute fetching
    
    open override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if globalHeaderPosition?.frame.intersects(rect) ?? false,
            let attribute = layoutAttributesForSupplementaryView(ofKind: collectionElementKindGlobalHeader, at: IndexPath(item: 0, section: 0)) {
            attributes.append(attribute)
        }
        if globalFooterPosition?.frame.intersects(rect) ?? false,
            let attribute = layoutAttributesForSupplementaryView(ofKind: collectionElementKindGlobalFooter, at: IndexPath(item: 0, section: 0)) {
            attributes.append(attribute)
        }
        
        for (sectionIndex, sectionRect) in sectionRects.enumerated() {
            if sectionRect.minY > rect.maxY { break }
            if sectionRect.intersects(rect) == false { continue }
            
            if sectionHeaderPositions[sectionIndex]?.frame.intersects(rect) ?? false,
                let attribute = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: sectionIndex)) {
                attributes.append(attribute)
            }
            
            for (index, item) in itemPositions[sectionIndex].enumerated() {
                if item.frame.minY > rect.maxY { break }
                if item.frame.intersects(rect),
                    let attribute = layoutAttributesForItem(at: IndexPath(item: index, section: sectionIndex)) {
                    attributes.append(attribute)
                }
            }
            
            if sectionFooterPositions[sectionIndex]?.frame.intersects(rect) ?? false,
                let attribute = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: sectionIndex)) {
                attributes.append(attribute)
            }
        }
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let position = itemPositions[ifExists: indexPath.section]?[ifExists: indexPath.item] {
            let attribute = CollectionViewFormLayoutAttributes(forCellWith: indexPath)
            attribute.frame         = position.frame
            attribute.zIndex        = position.zIndex
            attribute.layoutMargins = position.layoutMargins
            attribute.rowIndex      = position.rowIndex
            attribute.rowItemCount  = position.rowItemCount
            attribute.isAtTrailingEdge = position.isAtTrailingEdge
            return attribute
        }
        return nil
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var position: ElementPosition? = nil
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            let section = indexPath.section
            if sectionHeaderPositions.count > section, indexPath.item == 0 {
                position = sectionHeaderPositions[section]
            }
        case UICollectionElementKindSectionFooter:
            let section = indexPath.section
            if sectionFooterPositions.count > section, indexPath.item == 0 {
                position = sectionFooterPositions[section]
            }
        case collectionElementKindGlobalHeader:
            if indexPath.item == 0 && indexPath.section == 0 {
                position = globalHeaderPosition
            }
        case collectionElementKindGlobalFooter:
            if indexPath.item == 0 && indexPath.section == 0 {
                position = globalFooterPosition
            }
        default:
            break
        }
        
        guard let foundPosition = position else { return nil }
        
        let attribute = CollectionViewFormLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attribute.frame = foundPosition.frame
        attribute.zIndex = foundPosition.zIndex
        attribute.layoutMargins = foundPosition.layoutMargins
        return attribute
    }
    
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        // Don't perform an update if there is no width change, or if there is no content.
        if contentSize.width ==~ newBounds.width || sectionRects.last?.maxY.isZero ?? true  {
            // Width didn't change.
            updateGlobalHeaderAttributeIfNeeded(forBounds: newBounds)
            return false
        }
        
        return true
    }
    
    
    // MARK: - Column Conveniences
    
    /// Calculates the item content width per item in a column style section, optionally filling multiple items by
    /// merging columns together horizontally.
    ///
    /// - Parameters:
    ///   - fillingColumns:    The amount of columns to fill with the item. The default is 1.
    ///   - sectionColumns:    The amount of columns in the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The content width for an item that fills the specified (or 1) column in the defined layout.
    public func itemContentWidth(fillingColumns: Int = 1, inSectionWithColumns sectionColumns: Int, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let columnWidth = columnContentWidth(forColumnCount: sectionColumns, sectionEdgeInsets: sectionEdgeInsets)
        if fillingColumns <= 1 {
            return columnWidth
        }
        
        let additionalColumnWidth = (columnWidth + itemLayoutMargins.left + itemLayoutMargins.right) * CGFloat(fillingColumns - 1)
        return columnWidth + additionalColumnWidth
    }
    
    
    /// Calculats the item content width for an item that should fill across columns in a section until its minimum
    /// content width is reached. This is helpful for maintaining a column style layout, while observing minimum
    /// size constraints.
    ///
    /// - Parameters:
    ///   - minimumItemContentWidth: The minimum width the item's content should fill.
    ///   - sectionColumns:          The count of columns in the section.
    ///   - sectionEdgeInsets:       The edge insets for the section.
    /// - Returns:                   The content width for an item that fills to the edges of the columns in the section.
    ///                              This value is subpixel accurate and should be rounded appropriately for screen.
    public func itemContentWidth(fillingColumnsForMinimumItemContentWidth minimumItemContentWidth: CGFloat, inSectionWithColumns sectionColumns: Int, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let columnWidth = columnContentWidth(forColumnCount: sectionColumns, sectionEdgeInsets: sectionEdgeInsets)
        if minimumItemContentWidth <=~ 0.0 {
            return columnWidth
        }
        
        let insetWidth = itemLayoutMargins.left + itemLayoutMargins.right
        let totalColumnWidth = columnWidth + insetWidth
        let minimumItemTotalSize = minimumItemContentWidth + insetWidth
        
        let columnsFilled = max(minimumItemTotalSize / totalColumnWidth, 1.0)
        let totalItemWidth = columnsFilled * totalColumnWidth
        return totalItemWidth - insetWidth
    }
    
    
    /// Calculates the column count appropriate for a section with a certain minimum item width.
    ///
    /// - Parameters:
    ///   - itemWidth:         The minimum content width per item in the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The count of columns that will fit with the specified minimum content width and section details.
    public func columnCountForSection(withMinimumItemContentWidth itemWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> Int {
        precondition(itemWidth > 0.0, "itemWidth must be more than zero.")
        let standardizedSectionWidth = sectionWidthWithStandardMargins(sectionEdgeInsets: sectionEdgeInsets)
        let minimumTotalWidth = itemWidth + itemLayoutMargins.left + itemLayoutMargins.right
        return max(Int(standardizedSectionWidth / minimumTotalWidth), 1)
    }
    
    
    /// Calculates the content widths per column in a section.
    ///
    /// - Parameters:
    ///   - columnCount:       The column count for the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The content width appropriate for a section with the specified column and width settings.
    ///                        This value is subpixel accurate and should be rounded appropriately for screen.
    public func columnContentWidth(forColumnCount columnCount: Int, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let standardizedSectionWidth = sectionWidthWithStandardMargins(sectionEdgeInsets: sectionEdgeInsets)
        let totalColumnWidth = standardizedSectionWidth / CGFloat(columnCount)
        return totalColumnWidth - itemLayoutMargins.left - itemLayoutMargins.right
    }
    
    
    /// Calculates the content width for a column-based layout in a section, with columns calculated from a minimum item content width.
    ///
    /// - Parameters:
    ///   - itemWidth:          The minimum content width per item in the section.
    ///   - maximumColumnCount: The maximum column count
    ///   - sectionEdgeInsets:  The edge insets for the section.
    /// - Returns:              The content width appropriate for a section with the specified column and width settings.
    ///                         This value is subpixel accurate and should be rounded appropriately for screen.
    public func columnContentWidth(forMinimumItemContentWidth itemWidth: CGFloat, maximumColumnCount: Int = .max, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let standardizedSectionWidth = sectionWidthWithStandardMargins(sectionEdgeInsets: sectionEdgeInsets)
        let itemLayoutMargins = self.itemLayoutMargins
        let minimumTotalWidth = itemWidth + itemLayoutMargins.left + itemLayoutMargins.right
        let columnCount = min(max(floor(standardizedSectionWidth / minimumTotalWidth), 1.0), CGFloat(maximumColumnCount))
        let totalColumnWidth = standardizedSectionWidth / columnCount
        return totalColumnWidth - itemLayoutMargins.left - itemLayoutMargins.right
    }
    
    
    /// Calculates a section width for the section details, if it were to contain standard layout margins.
    /// This is a private convenience to ease math for column calculation.
    ///
    /// - Parameters:
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The width of the section if it were to contain standard layout margins.
    private func sectionWidthWithStandardMargins(sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        var sectionWidthWithStandardMargins = contentSize.width
        if sectionEdgeInsets.left.isZero == false {
            sectionWidthWithStandardMargins -= (sectionEdgeInsets.left - itemLayoutMargins.left)
        }
        if sectionEdgeInsets.right.isZero == false {
            sectionWidthWithStandardMargins -= (sectionEdgeInsets.right - itemLayoutMargins.right)
        }
        return sectionWidthWithStandardMargins
    }
    
}


// MARK: - CollectionViewDelegateFormLayout
@objc public protocol CollectionViewDelegateFormLayout: UICollectionViewDelegate {
    
    /// Asks the delegate for the minimum height for the item, given the width allocated to it.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    ///   - itemWidth:      The width for the item.
    /// - Returns:          The minimum required height for the item.
    func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentHeightForItemAt indexPath: IndexPath, givenContentWidth itemWidth: CGFloat) -> CGFloat
    
    
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
    /// - Returns:          The height of the header. If you return a value of 0.0, no header is added.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForHeaderInSection section: Int) -> CGFloat
    
    
    /// Asks the delegate for the height of the specified section footer.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose footer size is being requested.
    /// - Returns:          The height of the footer. If you return a value of 0.0, no footer is added.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForFooterInSection section: Int) -> CGFloat
    
    
    /// Asks the delegate for the margins to apply to content in the specified section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section whose insets are being requested.
    /// - Returns:          The margins to apply to items in the section.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, insetForSection section: Int) -> UIEdgeInsets
    
    
    /// Asks the delegate for the minimum width for the item, given the maximum width of the section.
    ///
    /// - Parameters:
    ///   - collectionView:    The collection view displaying the form layout.
    ///   - layout:            The layout object requesting the information.
    ///   - indexPath:         The indexPath for the item.
    ///   - sectionEdgeInsets: The insets for the section.
    /// - Returns:             The minimum required width for the item.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumContentWidthForItemAt indexPath: IndexPath, sectionEdgeInsets: UIEdgeInsets) -> CGFloat
    
    
    /// Asks the delegate if the layout should inset the section header into the section over the
    /// first row's top layout margin. If you don't implement this method, the layout defaults to
    /// the value of the `wantsInsetHeaders` property.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - section:        The index of the section header to optionally inset.
    /// - Returns:          `true` if the header should inset over the content, otherwise `false`.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, shouldInsetHeaderInSection section: Int) -> Bool
    
    
    /// Asks the delegate the height for the validation accessory under the item. If you don't
    /// implement this method, or return `0.0`, no accessory will be provided.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    ///   - contentWidth:   The content width for the item.
    /// - Returns:          The content height for the validation item. If you return `0.0`, no item is shown.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, heightForValidationAccessoryAt indexPath: IndexPath, givenContentWidth contentWidth: CGFloat) -> CGFloat
}
