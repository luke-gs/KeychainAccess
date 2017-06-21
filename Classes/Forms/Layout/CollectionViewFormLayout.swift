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
public let collectionElementKindSectionBackground = "collectionElementKindSectionBackground"


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
    
    
    // MARK: - Associated enums
    
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
    
    
    // MARK: - Public properties
    
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
    
    open var wantsOptimizedResizeAnimation: Bool = true
    
    
    /// Pins the global header, if it exists, to the visible space when bounce
    /// interactions occur.
    ///
    /// This avoids showing potentially undesirable empty content above the header.
    open var pinsGlobalHeaderWhenBouncing: Bool = false {
        didSet {
            if pinsGlobalHeaderWhenBouncing != oldValue && globalHeaderAttribute != nil,
                let collectionView = self.collectionView {
                updateGlobalHeaderAttributeIfNeeded(forBounds: collectionView.bounds)
            }
        }
    }
    
    
    /// The distribution method to use for cell sizing. The default is `CollectionViewFormLayout.Distribution.fillEqually`.
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
    
    
    // MARK: - Protected properties
    
    public var contentSize: CGSize = .zero
    public var sectionRects: [CGRect] = []
    
    public var globalHeaderAttribute: UICollectionViewLayoutAttributes?
    public var globalFooterAttribute: UICollectionViewLayoutAttributes?
    
    public var sectionHeaderAttributes:     [CollectionViewFormHeaderAttributes?] = []
    public var sectionFooterAttributes:     [UICollectionViewLayoutAttributes?]   = []
    public var sectionBackgroundAttributes: [UICollectionViewLayoutAttributes?]   = []
    
    public var itemAttributes: [[CollectionViewFormItemAttributes]] = []
    
    
    // MARK: - Private properties
    
    private var _lastLaidOutWidth: CGFloat?
    
    private var previousSectionItemCounts: [Int] = []
    
    
    // MARK: - Layout preparation
    
    open override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else { return }
        
        previousSectionItemCounts = itemAttributes.map { $0.count }
        
        let collectionViewBounds = collectionView.bounds
        _lastLaidOutWidth = collectionViewBounds.width
        
        let isRTL = collectionView.effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        let screenScale = (collectionView.window?.screen ?? .main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        
        sectionRects.removeAll(keepingCapacity: true)
        itemAttributes.removeAll(keepingCapacity: true)
        sectionHeaderAttributes.removeAll(keepingCapacity: true)
        sectionFooterAttributes.removeAll(keepingCapacity: true)
        sectionBackgroundAttributes.removeAll(keepingCapacity: true)
        
        let numberOfSections = collectionView.numberOfSections
        sectionRects.reserveCapacity(numberOfSections)
        itemAttributes.reserveCapacity(numberOfSections)
        sectionHeaderAttributes.reserveCapacity(numberOfSections)
        sectionFooterAttributes.reserveCapacity(numberOfSections)
        sectionBackgroundAttributes.reserveCapacity(numberOfSections)
        
        let itemLayoutMargins = self.itemLayoutMargins
        
        // function to process a section's items. ensure that insets are accounted for.
        func processItemsInSection(_ section: Int, atPoint point: CGPoint, withWidth width: CGFloat, sectionInsets: UIEdgeInsets) -> CGFloat { // Returns height of section items
            
            let sectionDistribution: CollectionViewFormLayout.Distribution
            if let foundDistribution = delegate.collectionView?(collectionView, layout: self, distributionForSection: section) , foundDistribution != .automatic {
                sectionDistribution = foundDistribution
            } else {
                sectionDistribution = self.distribution
            }
            
            var currentYOrigin = point.y
            
            let sectionLeftInset  = sectionInsets.left.rounded(toScale: screenScale)
            let sectionRightInset = sectionInsets.right.rounded(toScale: screenScale)
            
            let firstItemLeftWidthInset = sectionLeftInset.isZero  ? itemLayoutMargins.left  : 0.0
            let lastItemRightWidthInset = sectionRightInset.isZero ? itemLayoutMargins.right : 0.0
            
            let sectionWidth: CGFloat = width - sectionLeftInset - sectionRightInset
            
            let maximumAllowedWidth: CGFloat = sectionWidth - firstItemLeftWidthInset - lastItemRightWidthInset
            
            var itemMinWidths: [(IndexPath, CGFloat)] = (0..<collectionView.numberOfItems(inSection: section)).map {
                // Create a tuple representing the index path for this item in the section. Provide the minimum width, at maximum of either zero, or the minimum of width and the section width. This ensures an item width that can fit and will never be below zero.
                let indexPath = IndexPath(item: $0, section: section)
                let width: CGFloat = max(min((delegate.collectionView(collectionView, layout: self, minimumContentWidthForItemAt: indexPath, givenSectionWidth: width, edgeInsets: sectionInsets)).floored(toScale: screenScale), maximumAllowedWidth), 0.0)
                return (indexPath, width)
            }
            
            let sectionItemCount = itemMinWidths.count
            
            var sectionItemAttributes: [CollectionViewFormItemAttributes] = []
            sectionItemAttributes.reserveCapacity(sectionItemCount)
            
            let sectionItemStartY = currentYOrigin
            if sectionItemCount > 0 {
                
                var currentItemIndex = 0
                currentYOrigin += max(0.0, round(sectionInsets.top))
                
                var rowCount = 0
                func processRow() {
                    
                    var items: [(IndexPath, CGFloat)] = []
                    var minRowWidth: CGFloat = 0.0
                    var minRowContentWidths: CGFloat = 0.0
                    var rowItemCount = 0
                    
                    while currentItemIndex < sectionItemCount {
                        let item = itemMinWidths[currentItemIndex]
                        
                        let newMinRowWidth: CGFloat
                        if rowItemCount == 0 {
                            newMinRowWidth = item.1 + firstItemLeftWidthInset
                        } else {
                            newMinRowWidth = minRowWidth + itemLayoutMargins.left + itemLayoutMargins.right + item.1
                        }
                        if (newMinRowWidth + lastItemRightWidthInset) > ceil(sectionWidth) && items.isEmpty == false { break }
                        
                        items.append(item)
                        minRowWidth = newMinRowWidth
                        minRowContentWidths += item.1
                        rowItemCount += 1
                        currentItemIndex += 1
                    }
                    if rowItemCount > 0 {
                        // We've now got all items in the section. Work out how much extra space we have.
                        
                        let rowItemCountFloat = CGFloat(rowItemCount)
                        let insetSpace = (rowItemCountFloat - 1.0) * (itemLayoutMargins.left + itemLayoutMargins.right) + firstItemLeftWidthInset + lastItemRightWidthInset
                        
                        let leftOverSpace = max(sectionWidth - insetSpace - minRowContentWidths, 0.0)
                        let extraSpacePerItem    = sectionDistribution == .fillEqually ? (leftOverSpace / rowItemCountFloat).floored(toScale: screenScale) : 0.0
                        var extraAllocationWidth = sectionDistribution == .fillEqually ? (leftOverSpace * screenScale).truncatingRemainder(dividingBy: rowItemCountFloat) / screenScale : 0.0
                        
                        var minHeight:     CGFloat = 0.0
                        var currentXValue: CGFloat = point.x
                        
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
                            
                            let itemMinHeight = ceil(delegate.collectionView(collectionView, layout: self, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: newContentWidth))
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
                        
                        for (index, item) in rowItems.enumerated() {
                            let itemAttribute = CollectionViewFormItemAttributes(forCellWith: item.0)
                            itemAttribute.zIndex = 1
                            itemAttribute.rowIndex = index
                            itemAttribute.rowItemCount = rowItemCount
                            
                            var frame = item.frame
                            itemAttribute.isAtTrailingEdge = fabs(frame.maxX - collectionViewBounds.width) < 0.5
                            
                            frame.size.height = minHeight
                            itemAttribute.frame = isRTL ? frame.rtlFlipped(forWidth: collectionViewBounds.width) : frame
                            itemAttribute.layoutMargins = isRTL ? item.margins.horizontallyFlipped() : item.margins
                            
                            sectionItemAttributes.append(itemAttribute)
                        }
                        
                        currentYOrigin += minHeight
                    }
                    
                    rowCount += 1
                }
                
                // Process the rows from the minWidth
                while currentItemIndex < sectionItemCount {
                    processRow()
                }
            }
            
            itemAttributes.append(sectionItemAttributes)
            
            return currentYOrigin + max(0.0, round(sectionInsets.bottom)) - point.y
        }
        
        var currentYOffset: CGFloat = 0.0
        
        if let globalHeaderHeight = delegate.collectionView?(collectionView, heightForGlobalHeaderInLayout: self) , globalHeaderHeight > 0.0 {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindGlobalHeader, with: IndexPath(item: 0, section: 0))
            let headerOriginY: CGFloat
            if pinsGlobalHeaderWhenBouncing {
                headerOriginY = min(currentYOffset, collectionViewBounds.minY + collectionView.contentInset.top)
            } else {
                headerOriginY = currentYOffset
            }
            
            attribute.frame = CGRect(x: 0.0, y: headerOriginY, width: collectionViewBounds.width, height: ceil(globalHeaderHeight))
            attribute.zIndex = 1
            globalHeaderAttribute = attribute
            currentYOffset += ceil(globalHeaderHeight)
        } else {
            globalHeaderAttribute = nil
        }
        
        // Each section is grouped with a group horizontally, to attempt to layout side-by-side.
        let sectionGroups: [[(Int, (x: CGFloat, width: CGFloat))]]
        
        if delegate.responds(to: #selector(CollectionViewDelegateFormLayout.collectionView(_:layout:minimumWidthForSection:))) {
            let widths = (0..<numberOfSections).map {($0, min(floor(delegate.collectionView!(collectionView, layout: self, minimumWidthForSection: $0)), collectionViewBounds.width)) }
            var groups: [[(Int, (x: CGFloat, width: CGFloat))]] = []
            
            var sectionPreferredWidths = widths
            while sectionPreferredWidths.isEmpty == false {
                var width: CGFloat = 0.0
                var sectionItems: [Int] = []
                while width < collectionViewBounds.width {
                    guard let newProposedItem = sectionPreferredWidths.first else { break }
                    let newProposedWidth = width + newProposedItem.1
                    if newProposedWidth > collectionViewBounds.width { break }
                    sectionItems.append(newProposedItem.0)
                    sectionPreferredWidths.removeFirst()
                    width = newProposedWidth
                }
                if sectionItems.isEmpty { break }
                let leftOverPerItem = (collectionViewBounds.width - width) / CGFloat(sectionItems.count)
                
                var originX: CGFloat = 0.0
                var items: [(Int, (x: CGFloat, width: CGFloat))] = []
                for section in sectionItems {
                    let width = ceil(widths[section].1 + leftOverPerItem)
                    items.append((section, (x: originX, width: width)))
                    originX += width
                }
                groups.append(items)
            }
            sectionGroups = groups
        }
        else {
            sectionGroups = (0..<numberOfSections).map{[($0, (x: 0.0, width: collectionViewBounds.width))]}
        }
        
        
        let defaultWantsSectionHeaderInsets = wantsInsetHeaders
        
        for sectionGroup: [(Int, (x: CGFloat, width: CGFloat))] in sectionGroups {
            
            var sectionIndentAdded: Bool = false
            
            // process each section group
            let startOfHeaders = currentYOffset
            
            // First get headers, work out the taller of them, and add them putting them to the bottom as much as possible
            var largestHeight: CGFloat = 0.0
            let headerRects: [(section: Int, headerRect: CGRect, sectionInsets: UIEdgeInsets)] = sectionGroup.map {
                let width = $1.width
                let height = max(ceil(delegate.collectionView(collectionView, layout: self, heightForHeaderInSection: $0, givenSectionWidth: width)), 0.0)
                largestHeight = max(largestHeight, height)
                let edgeInsets = delegate.collectionView(collectionView, layout: self, insetForSection: $0, givenSectionWidth: width)
                return ($0, CGRect(x: $1.x, y: 0.0, width: width, height: height), edgeInsets)
            }
            currentYOffset += largestHeight
            
            var maxHeaderInsetAdded: CGFloat = 0.0
            
            for headerRect in headerRects {
                var rect    = headerRect.1
                let height = rect.size.height
                
                if height.isZero {
                    sectionHeaderAttributes.append(nil)
                } else {
                    rect.origin.y = currentYOffset - height
                    
                    let sectionIndexPath = IndexPath(item: 0, section: headerRect.0)
                    let headerAttribute = CollectionViewFormHeaderAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: sectionIndexPath)
                    headerAttribute.zIndex = 1
                    
                    var sectionInset = headerRect.2.left
                    if sectionInset.isZero {
                        sectionInset = itemLayoutMargins.left
                    }
                    
                    headerAttribute.leadingMargin = sectionInset
                    
                    let wantsInsetSectionHeader = delegate.collectionView?(collectionView, layout: self, shouldInsetHeaderInSection: sectionIndexPath.section) ?? defaultWantsSectionHeaderInsets
                    if wantsInsetSectionHeader {
                        if sectionIndentAdded == false {
                            sectionIndentAdded = true
                        }
                        
                        headerAttribute.itemPosition = rect.size.height
                        rect.size.height += itemLayoutMargins.top
                        maxHeaderInsetAdded = max(maxHeaderInsetAdded, itemLayoutMargins.top)
                    }
                    headerAttribute.frame = isRTL ? rect.rtlFlipped(forWidth: collectionViewBounds.width) : rect
                    sectionHeaderAttributes.append(headerAttribute)
                }
            }
            
            let startOfItems = currentYOffset
            
            // Put each of the section item columns in place.
            var maxSectionHeight: CGFloat = 0.0
            for (rowIndex, section) in sectionGroup.enumerated() {
                maxSectionHeight = max(maxSectionHeight, processItemsInSection(section.0, atPoint: CGPoint(x: section.1.x, y: startOfItems), withWidth: section.1.width, sectionInsets: headerRects[rowIndex].2))
            }
            if maxSectionHeight == 0.0 && sectionIndentAdded {
                maxSectionHeight += maxHeaderInsetAdded.ceiled(toScale: screenScale)
            }
            currentYOffset += maxSectionHeight
            
            // Place in the footer views
            var largestFooter: CGFloat = 0.0
            for section in sectionGroup {
                let width = section.1.width
                let footerHeight = max(ceil(delegate.collectionView(collectionView, layout: self, heightForFooterInSection: section.0, givenSectionWidth: width)), 0.0)
                largestFooter = max(footerHeight, largestFooter)
                
                if footerHeight.isZero {
                    sectionFooterAttributes.append(nil)
                } else {
                    let footerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section.0))
                    footerAttribute.zIndex = 1
                    let footerFrame = CGRect(x: section.1.x, y: currentYOffset, width: section.1.width, height: footerHeight)
                    footerAttribute.frame = isRTL ? footerFrame.rtlFlipped(forWidth: collectionViewBounds.width) : footerFrame
                    sectionFooterAttributes.append(footerAttribute)
                }
                
                sectionRects.append(CGRect(x: section.1.x, y: startOfHeaders, width: width, height: currentYOffset + footerHeight - startOfHeaders))
            }
            
            currentYOffset += largestFooter
            
            var minBackgroundHeight: CGFloat = 0.0
            let sectionBackgrounds: [(section: Int, (x: CGFloat, width: CGFloat))?] = sectionGroup.map {
                if delegate.collectionView?(collectionView, layout: self, wantsBackgroundInSection: $0.0) ?? false {
                    let height = max(delegate.collectionView?(collectionView, layout: self, minimumHeightForBackgroundInSection: $0.0, givenSectionWidth: $0.1.width) ?? 0.0, 0.0)
                    minBackgroundHeight = max(height, minBackgroundHeight)
                    return $0
                } else {
                    return nil
                }
            }
            
            if (currentYOffset - startOfHeaders) < minBackgroundHeight {
                currentYOffset = (startOfHeaders + minBackgroundHeight).ceiled(toScale: screenScale)
            }
            
            for background in sectionBackgrounds {
                if let background = background {
                    let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindSectionBackground, with: IndexPath(item: 0, section: background.0))
                    let backgroundFrame = CGRect(x: background.1.x, y: startOfHeaders, width: background.1.width, height: currentYOffset - startOfHeaders)
                    attribute.frame = isRTL ? backgroundFrame.rtlFlipped(forWidth: collectionViewBounds.width) : backgroundFrame
                    sectionBackgroundAttributes.append(attribute)
                } else {
                    sectionBackgroundAttributes.append(nil)
                }
            }
        }
        
        if let globalFooterHeight = delegate.collectionView?(collectionView, heightForGlobalFooterInLayout: self) , globalFooterHeight > 0.0 {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindGlobalFooter, with: IndexPath(item: 0, section: 0))
            attribute.frame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewBounds.width, height: ceil(globalFooterHeight))
            attribute.zIndex = 1
            globalFooterAttribute = attribute
            currentYOffset += ceil(globalFooterHeight)
        } else {
            globalFooterAttribute = nil
        }
        
        contentSize = CGSize(width: collectionViewBounds.width, height: currentYOffset)
    }
    
    private func updateGlobalHeaderAttributeIfNeeded(forBounds bounds: CGRect) {
        guard let globalHeaderAttribute = self.globalHeaderAttribute else { return }
        
        let correctYOrigin: CGFloat
        if pinsGlobalHeaderWhenBouncing, let collectionView = self.collectionView {
            correctYOrigin = min(0.0, bounds.minY + collectionView.contentInset.top)
        } else {
            correctYOrigin = 0.0
        }
        
        var globalHeaderFrame = globalHeaderAttribute.frame
        if globalHeaderFrame.minY ==~ correctYOrigin { return }
        
        globalHeaderFrame.origin.y = correctYOrigin
        globalHeaderAttribute.frame = globalHeaderFrame
            
        let context = UICollectionViewLayoutInvalidationContext()
        context.invalidateSupplementaryElements(ofKind: collectionElementKindGlobalHeader, at: [globalHeaderAttribute.indexPath])
        invalidateLayout(with: context)
    }
    
    
    // MARK: - Layout attribute fetching
    
    open override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if let globalHeaderAttribute = self.globalHeaderAttribute,
            globalHeaderAttribute.frame.intersects(rect) {
            attributes.append(globalHeaderAttribute)
        }
        if let globalFooterAttribute = self.globalFooterAttribute,
            globalFooterAttribute.frame.intersects(rect) {
            attributes.append(globalFooterAttribute)
        }
        
        for (sectionIndex, sectionRect) in sectionRects.enumerated() {
            if sectionRect.minY > rect.maxY { break }
            if sectionRect.intersects(rect) == false { continue }
            
            if let backgroundAttribute = sectionBackgroundAttributes[sectionIndex],
                backgroundAttribute.frame.intersects(rect) {
                attributes.append(backgroundAttribute)
            }
            
            if let sectionHeaderItem = sectionHeaderAttributes[sectionIndex],
                sectionHeaderItem.frame.intersects(rect) {
                attributes.append(sectionHeaderItem)
            }
            
            for item in itemAttributes[sectionIndex] {
                let frame = item.frame
                if frame.minY > rect.maxY { break }
                if frame.intersects(rect) {
                    attributes.append(item)
                }
            }
            if let sectionFooterItem = sectionFooterAttributes[sectionIndex],
                sectionFooterItem.frame.intersects(rect) {
                attributes.append(sectionFooterItem)
            }
        }
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            if let item = sectionHeaderAttributes[ifExists: indexPath.section] { return item }
        case UICollectionElementKindSectionFooter:
            if let item = sectionFooterAttributes[ifExists: indexPath.section] { return item }
        case collectionElementKindGlobalHeader:
            if let header = globalHeaderAttribute, indexPath == header.indexPath { return header }
        case collectionElementKindGlobalFooter:
            if let footer = globalFooterAttribute, indexPath == footer.indexPath { return footer }
        case collectionElementKindSectionBackground:
            if let background = sectionBackgroundAttributes[ifExists: indexPath.section] { return background }
        default:
            break
        }
        
        return nil
    }
    
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let currentContentWidth = _lastLaidOutWidth ?? 0.0
        let newWidth = fabs(newBounds.width)
        
        // Don't perform an update if there is no width change, or if there is no content.
        
        if currentContentWidth ==~ newWidth || sectionRects.last?.maxY.isZero ?? true  {
            // Width didn't change.
            updateGlobalHeaderAttributeIfNeeded(forBounds: newBounds)
            return false
        }
        
        if wantsOptimizedResizeAnimation == false {
            return true
        }
        
        // We're going to do the animation direct - it's much faster.
        
        let animationDuration = UIView.inheritedAnimationDuration
        if animationDuration <=~ 0.0 || UIView.areAnimationsEnabled == false { return true }
        
        let collectionView = self.collectionView!
        
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
                collectionView.scrollToItem(at: firstIP, at: [], animated: false)
            }
            
            collectionView.layoutIfNeeded()
            
            let transition = CATransition()
            transition.duration = animationDuration
            transition.timingFunction = CAMediaTimingFunction(name: newWidth > currentContentWidth ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn)
            collectionView.layer.add(transition, forKey: nil)
        }
        
        return false
    }
    
    
    // MARK: - Updates
    
    private var insertedSections:      IndexSet?
    private var deletedSections:       IndexSet?
    private var insertedItems:         [IndexPath]?
    private var deletedItems:          [IndexPath]?
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = self.collectionView else { return }
        
        var insertedSections = IndexSet()
        var deletedSections  = IndexSet()
        
        var insertedItems: [IndexPath] = []
        var deletedItems:  [IndexPath] = []
        
        for item in updateItems {
            if (item.indexPathBeforeUpdate ?? item.indexPathAfterUpdate)?.row == NSIntegerMax {
                // Section updates
                switch item.updateAction {
                case .insert:
                    let section = item.indexPathAfterUpdate!.section
                    insertedSections.insert(section)
                    insertedItems += (0..<collectionView.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .delete:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedSections.insert(section)
                    deletedItems += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                case .reload:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedItems += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                    insertedItems += (0..<collectionView.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .move:
                    let oldSection = item.indexPathBeforeUpdate!.section
                    deletedSections.insert(oldSection)
                    deletedItems += (0..<previousSectionItemCounts[oldSection]).map { IndexPath(item: $0, section: oldSection) }
                    let newSection = item.indexPathAfterUpdate!.section
                    insertedSections.insert(newSection)
                    insertedItems += (0..<collectionView.numberOfItems(inSection: newSection)).map { IndexPath(item: $0, section: newSection) }
                case .none:
                    break
                }
            } else {
                // Item update
                switch item.updateAction {
                case .insert:
                    insertedItems.append(item.indexPathAfterUpdate!)
                case .delete:
                    deletedItems.append(item.indexPathBeforeUpdate!)
                case .move:
                    deletedItems.append(item.indexPathBeforeUpdate!)
                    insertedItems.append(item.indexPathAfterUpdate!)
                default:
                    break
                }
            }
        }
        
        self.insertedSections = insertedSections
        self.deletedSections  = deletedSections
        self.insertedItems    = insertedItems
        self.deletedItems     = deletedItems
    }
    
    open override func finalizeCollectionViewUpdates() {
        insertedItems    = nil
        deletedItems     = nil
        insertedSections = nil
        deletedSections  = nil
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if insertedSections?.contains(itemIndexPath.section) ?? false || insertedItems?.contains(itemIndexPath) ?? false {
            attributes?.alpha = 0.0
        }
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if deletedItems?.contains(itemIndexPath) ?? false || deletedSections?.contains(itemIndexPath.section) ?? false {
            attributes?.alpha = 0.0
        }
        return attributes
    }
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if insertedSections?.contains(elementIndexPath.section) ?? false {
            attributes?.alpha = 0.0
        }
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if deletedSections?.contains(elementIndexPath.section) ?? false {
            attributes?.alpha = 0.0
        }
        return attributes
    }
    
    
    // MARK: - Column Conveniences
    
    
    /// Calculates the item content width per item in a column style section, optionally filling multiple items by
    /// merging columns together horizontally.
    ///
    /// - Parameters:
    ///   - fillingColumns:    The amount of columns to fill with the item. The default is 1.
    ///   - sectionColumns:    The amount of columns in the section.
    ///   - sectionWidth:      The width for the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The content width for an item that fills the specified (or 1) column in the defined layout.
    public func itemContentWidth(fillingColumns: Int = 1, inSectionWithColumns sectionColumns: Int, sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let columnWidth = columnContentWidth(forColumnCount: sectionColumns, inSectionWidth: sectionWidth, sectionEdgeInsets: sectionEdgeInsets)
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
    ///   - sectionWidth:            The width for the section.
    ///   - sectionEdgeInsets:       The edge insets for the section.
    /// - Returns:                   The content width for an item that fills to the edges of the columns in the section.
    ///                              This value is subpixel accurate and should be rounded appropriately for screen.
    public func itemContentWidth(fillingColumnsForMinimumItemContentWidth minimumItemContentWidth: CGFloat, inSectionWithColumns sectionColumns: Int, sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let columnWidth = columnContentWidth(forColumnCount: sectionColumns, inSectionWidth: sectionWidth, sectionEdgeInsets: sectionEdgeInsets)
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
    ///   - sectionWidth:      The width for the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The count of columns that will fit with the specified minimum content width and section details.
    public func columnCountForSection(withMinimumItemContentWidth itemWidth: CGFloat, sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> Int {
        precondition(itemWidth > 0.0, "itemWidth must be more than zero.")
        let standardizedSectionWidth = sectionWidthWithStandardMargins(forSectionWidth: sectionWidth, sectionEdgeInsets: sectionEdgeInsets)
        let minimumTotalWidth = itemWidth + itemLayoutMargins.left + itemLayoutMargins.right
        return max(Int(standardizedSectionWidth / minimumTotalWidth), 1)
    }
    
    
    /// Calculates the content widths per column in a section.
    ///
    /// - Parameters:
    ///   - columnCount:       The column count for the section.
    ///   - sectionWidth:      The total width for the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The content width appropriate for a section with the specified column and width settings.
    ///                        This value is subpixel accurate and should be rounded appropriately for screen.
    public func columnContentWidth(forColumnCount columnCount: Int, inSectionWidth sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let standardizedSectionWidth = sectionWidthWithStandardMargins(forSectionWidth: sectionWidth, sectionEdgeInsets: sectionEdgeInsets)
        let totalColumnWidth = standardizedSectionWidth / CGFloat(columnCount)
        return totalColumnWidth - itemLayoutMargins.left - itemLayoutMargins.right
    }
    
    
    /// Calculates the content width for a column-based layout in a section, with columns calculated from a minimum item content width.
    ///
    /// - Parameters:
    ///   - itemWidth:          The minimum content width per item in the section.
    ///   - maximumColumnCount: The maximum column count
    ///   - sectionWidth:       The width for the section.
    ///   - sectionEdgeInsets:  The edge insets for the section.
    /// - Returns:              The content width appropriate for a section with the specified column and width settings.
    ///                         This value is subpixel accurate and should be rounded appropriately for screen.
    public func columnContentWidth(forMinimumItemContentWidth itemWidth: CGFloat, maximumColumnCount: Int = .max, sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        let standardizedSectionWidth = sectionWidthWithStandardMargins(forSectionWidth: sectionWidth, sectionEdgeInsets: sectionEdgeInsets)
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
    ///   - sectionWidth:      The total width for the section.
    ///   - sectionEdgeInsets: The edge insets for the section.
    /// - Returns:             The width of the section if it were to contain standard layout margins.
    private func sectionWidthWithStandardMargins(forSectionWidth sectionWidth: CGFloat, sectionEdgeInsets: UIEdgeInsets) -> CGFloat {
        var sectionWidthWithStandardMargins = sectionWidth
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
    
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, shouldInsetHeaderInSection section: Int) -> Bool
    
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, wantsBackgroundInSection section: Int) -> Bool
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, minimumHeightForBackgroundInSection section: Int, givenSectionWidth sectionWidth: CGFloat) -> CGFloat
}
