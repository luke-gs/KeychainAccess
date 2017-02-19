//
//  CollectionViewFormLayoutBoxedStyle.swift
//  MPOLKit
//
//  Created by Rod Brown on 19/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class CollectionViewFormLayoutBoxedStyle: CollectionViewFormLayoutStyle {
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let layout = self.formLayout,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else { return }
        
        let collectionViewWidth = collectionView.bounds.width
        
        let screenScale = (collectionView.window?.screen ?? .main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        let separatorWidth = layout.separatorWidth
        let separatorVerticalSpacing = separatorWidth.ceiled(toScale: screenScale) // This value represents a pixel-aligned adjustment to ensure we don't get blurry cells.
        
        let wantsSectionSeparators        = layout.wantsSectionSeparators
        let wantsHorizontalItemSeparators = layout.wantsHorizontalItemSeparators
        let wantsVerticalItemSeparators   = layout.wantsVerticalItemSeparators
        let wantsSectionBackgrounds       = layout.wantsSectionBackgrounds
        
        var reusableSectionHeaderAttributes: [UICollectionViewLayoutAttributes] = []
        for item in sectionHeaderAttributes where item != nil {
            if let realItem = item { reusableSectionHeaderAttributes.append(realItem) }
        }
        var reusableSectionFooterAttributes: [UICollectionViewLayoutAttributes] = []
        
        for item in sectionFooterAttributes where item != nil {
            if let realItem = item { reusableSectionFooterAttributes.append(realItem) }
        }
        var reusableSectionBackgroundAttributes = wantsSectionBackgrounds ? sectionBackgroundAttributes : []
        var reusableItemAttributes = itemAttributes.flatMap { $0 }
        
        var reusableSectionSeparators: [CollectionViewFormDecorationAttributes] = []
        if wantsSectionSeparators {
            reusableSectionSeparators.reserveCapacity(sectionSeparatorAttributes.count * 3)
            for section in sectionSeparatorAttributes {
                reusableSectionSeparators.append(contentsOf: section)
            }
        }
        
        var reusableRowSeparators  = wantsHorizontalItemSeparators ? rowSeparatorAttributes.flatMap{$0}  : []
        var reusableItemSeparators = wantsVerticalItemSeparators   ? itemSeparatorAttributes.flatMap{$0} : []
        
        sectionRects.removeAll(keepingCapacity: true)
        itemAttributes.removeAll(keepingCapacity: true)
        sectionHeaderAttributes.removeAll(keepingCapacity: true)
        sectionFooterAttributes.removeAll(keepingCapacity: true)
        sectionBackgroundAttributes.removeAll(keepingCapacity: wantsSectionBackgrounds)
        sectionSeparatorAttributes.removeAll(keepingCapacity: wantsSectionSeparators)
        rowSeparatorAttributes.removeAll(keepingCapacity: wantsHorizontalItemSeparators)
        itemSeparatorAttributes.removeAll(keepingCapacity: wantsVerticalItemSeparators)
        
        let delegateSupportsHidingHorizontalSeparators = wantsHorizontalItemSeparators && delegate.responds(to: #selector(CollectionViewDelegateFormLayout.collectionView(_:layout:shouldDisplayHorizontalSeparatorForItemAt:)))
        let delegateSupportsHidingVerticalSeparators = wantsVerticalItemSeparators && delegate.responds(to: #selector(CollectionViewDelegateFormLayout.collectionView(_:layout:shouldDisplayVerticalSeparatorBelowItemAt:)))
        
        let numberOfSections = collectionView.numberOfSections
        sectionRects.reserveCapacity(numberOfSections)
        itemAttributes.reserveCapacity(numberOfSections)
        sectionHeaderAttributes.reserveCapacity(numberOfSections)
        sectionFooterAttributes.reserveCapacity(numberOfSections)
        sectionBackgroundAttributes.reserveCapacity(numberOfSections)
        sectionSeparatorAttributes.reserveCapacity(numberOfSections)
        rowSeparatorAttributes.reserveCapacity(numberOfSections)
        itemSeparatorAttributes.reserveCapacity(numberOfSections)
        
        let itemLayoutMargins = layout.itemLayoutMargins
        
        let itemSeparatorColor = layout.itemSeparatorColor
        let sectionSeparatorColor = layout.sectionSeparatorColor
        
        // function to process a section's items. ensure that insets are accounted for.
        func processItemsInSection(_ section: Int, atPoint point: CGPoint, withWidth width: CGFloat) -> CGFloat { // Returns height of section items
            
            let sectionDistribution: CollectionViewFormLayout.Distribution
            if let foundDistribution = delegate.collectionView?(collectionView, layout: layout, distributionForSection: section) , foundDistribution != .automatic {
                sectionDistribution = foundDistribution
            } else {
                sectionDistribution = layout.distribution
            }
            
            var currentYOrigin = point.y
            
            let insets = delegate.collectionView(collectionView, layout: layout, insetForSection: section, givenSectionWidth: width)
            let sectionLeftInset  = insets.left.rounded(toScale: screenScale)
            let sectionRightInset = insets.right.rounded(toScale: screenScale)
            
            let firstItemLeftWidthInset = sectionLeftInset.isZero ? itemLayoutMargins.left : 0.0
            let lastItemRightWidthInset = sectionRightInset.isZero ? itemLayoutMargins.right : 0.0
            
            let sectionWidth: CGFloat = width - sectionLeftInset - sectionRightInset
            
            let maximumAllowedWidth: CGFloat = sectionWidth - firstItemLeftWidthInset - lastItemRightWidthInset
            
            var itemMinWidths: [(IndexPath, CGFloat)] = (0..<collectionView.numberOfItems(inSection: section)).map {
                // Create a tuple representing the index path for this item in the section. Provide the minimum width, at maximum of either zero, or the minimum of width and the section width. This ensures an item width that can fit and will never be below zero.
                let indexPath = IndexPath(item: $0, section: section)
                let width: CGFloat = max(min((delegate.collectionView(collectionView, layout: layout, minimumContentWidthForItemAt: indexPath, givenSectionWidth: width, edgeInsets: insets)).floored(toScale: screenScale), maximumAllowedWidth), 0.0)
                return (indexPath, width)
            }
            
            let sectionItemCount = itemMinWidths.count
            
            var sectionItemAttributes: [CollectionViewFormItemAttributes] = []
            sectionItemAttributes.reserveCapacity(sectionItemCount)
            
            var sectionRowAttributes:  [CollectionViewFormDecorationAttributes] = []
            var sectionItemSepAttributes: [CollectionViewFormDecorationAttributes] = []
            sectionItemSepAttributes.reserveCapacity(sectionItemCount)
            
            let sectionItemStartY = currentYOrigin
            if sectionItemCount > 0 {
                
                var currentItemIndex = 0
                currentYOrigin += max(0.0, round(insets.top))
                
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
                        if (newMinRowWidth + lastItemRightWidthInset) > ceil(sectionWidth) { break }
                        
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
                        let extraSpacePerItem = sectionDistribution == .fillEqually ? (leftOverSpace / rowItemCountFloat).floored(toScale: screenScale) : 0.0
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
                            
                            if index == rowItemCount - 1 && sectionDistribution == .fillLast {
                                newContentWidth += leftOverSpace
                            }
                            
                            let itemMinHeight = ceil(delegate.collectionView(collectionView, layout: layout, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: newContentWidth))
                            if minHeight < itemMinHeight { minHeight = itemMinHeight }
                            
                            if rowItemCount == 1 {
                                var insets = UIEdgeInsets(top: itemLayoutMargins.top, left: sectionLeftInset.isZero ? itemLayoutMargins.left : sectionLeftInset, bottom: itemLayoutMargins.bottom, right: itemLayoutMargins.right)
                                
                                let proposedEndOfContent = currentXValue + newContentWidth + insets.left
                                let endOfMaxContent      = collectionViewWidth - (sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
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
                                var insets = itemLayoutMargins
                                let proposedEndOfContent = currentXValue + newContentWidth + insets.left
                                let endOfMaxContent      = collectionViewWidth - (sectionRightInset.isZero ? itemLayoutMargins.right : sectionRightInset)
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
                        
                        for item in rowItems {
                            let itemAttribute: CollectionViewFormItemAttributes
                            let indexPath = item.0
                            if let dequeuedAttributes = reusableItemAttributes.popLast() {
                                dequeuedAttributes.indexPath = indexPath
                                itemAttribute = dequeuedAttributes
                            } else {
                                itemAttribute = CollectionViewFormItemAttributes(forCellWith: indexPath)
                                itemAttribute.zIndex = 1
                            }
                            
                            var frame = item.frame
                            frame.size.height = minHeight
                            itemAttribute.frame = frame
                            itemAttribute.layoutMargins = item.margins
                            
                            sectionItemAttributes.append(itemAttribute)
                            
                            if wantsVerticalItemSeparators {
                                let separator: CollectionViewFormDecorationAttributes
                                if let dequeuedAttribute = reusableItemSeparators.popLast() {
                                    dequeuedAttribute.indexPath = indexPath
                                    separator = dequeuedAttribute
                                } else {
                                    separator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorItem, with: indexPath)
                                    separator.zIndex = 2
                                }
                                separator.backgroundColor = itemSeparatorColor
                                let separatorFrame = CGRect(x: frame.maxX - separatorWidth, y: frame.minY - separatorVerticalSpacing + separatorWidth, width: separatorWidth, height: minHeight)
                                separator.frame = separatorFrame
                                if delegateSupportsHidingHorizontalSeparators {
                                    separator.alpha = separatorFrame.maxX < collectionViewWidth && delegate.collectionView!(collectionView, layout: layout, shouldDisplayHorizontalSeparatorForItemAt: indexPath) ? 1.0 : 0.0
                                } else {
                                    separator.alpha = separatorFrame.maxX < collectionViewWidth ? 1.0 : 0.0
                                }
                                
                                sectionItemSepAttributes.append(separator)
                            }
                        }
                        
                        currentYOrigin += minHeight
                        
                        if wantsHorizontalItemSeparators {
                            let separator: CollectionViewFormDecorationAttributes
                            let indexPath = IndexPath(item: rowCount, section: section)
                            if let dequeuedAttribute = reusableRowSeparators.popLast() {
                                dequeuedAttribute.indexPath = indexPath
                                separator = dequeuedAttribute
                            } else {
                                separator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorRow, with: indexPath)
                                separator.zIndex = 2
                            }
                            separator.backgroundColor = sectionSeparatorColor
                            
                            let originX = point.x + sectionLeftInset
                            separator.frame = CGRect(x: originX, y: currentYOrigin + separatorVerticalSpacing - separatorWidth, width: sectionWidth, height: separatorWidth)
                            separator.isHidden = delegateSupportsHidingVerticalSeparators && (delegate.collectionView!(collectionView, layout: layout, shouldDisplayVerticalSeparatorBelowItemAt: rowItems.last!.ip) == false)
                            currentYOrigin += separatorVerticalSpacing
                            sectionRowAttributes.append(separator)
                        }
                    }
                    
                    rowCount += 1
                }
                
                // Process the rows from the minWidth
                while currentItemIndex < sectionItemCount {
                    processRow()
                }
            }
            
            itemAttributes.append(sectionItemAttributes)
            itemSeparatorAttributes.append(sectionItemSepAttributes)
            rowSeparatorAttributes.append(sectionRowAttributes)
            
            return currentYOrigin + max(0.0, round(insets.bottom)) - point.y
        }
        
        var currentYOffset: CGFloat = 0.0
        
        if let globalHeaderHeight = delegate.collectionView?(collectionView, heightForGlobalHeaderInLayout: layout) , globalHeaderHeight > 0.0 {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindGlobalHeader, with: IndexPath(index: 0))
            attribute.frame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewWidth, height: ceil(globalHeaderHeight))
            attribute.zIndex = 1
            globalHeaderAttribute = attribute
            currentYOffset += ceil(globalHeaderHeight)
        } else {
            globalHeaderAttribute = nil
        }
        
        // Each section is grouped with a group horizontally, to attempt to layout side-by-side.
        let sectionGroups: [[(Int, (x: CGFloat, width: CGFloat))]]
        
        if delegate.responds(to: #selector(CollectionViewDelegateFormLayout.collectionView(_:layout:minimumWidthForSection:))) {
            let widths = (0..<numberOfSections).map {($0, min(floor(delegate.collectionView!(collectionView, layout: layout, minimumWidthForSection: $0)), collectionViewWidth)) }
            var groups: [[(Int, (x: CGFloat, width: CGFloat))]] = []
            
            var sectionPreferredWidths = widths
            while sectionPreferredWidths.isEmpty == false {
                var width: CGFloat = 0.0
                var sectionItems: [Int] = []
                while width < collectionViewWidth {
                    guard let newProposedItem = sectionPreferredWidths.first else { break }
                    let newProposedWidth = width + newProposedItem.1
                    if newProposedWidth > collectionViewWidth { break }
                    sectionItems.append(newProposedItem.0)
                    sectionPreferredWidths.removeFirst()
                    width = newProposedWidth
                }
                if sectionItems.isEmpty { break }
                let leftOverPerItem = (collectionViewWidth - width) / CGFloat(sectionItems.count)
                
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
            sectionGroups = (0..<numberOfSections).map{[($0, (x: 0.0, width: collectionViewWidth))]}
        }
        
        for sectionGroup: [(Int, (x: CGFloat, width: CGFloat))] in sectionGroups {
            // process each section group
            let startOfHeaders = currentYOffset
            
            // First get headers, work out the taller of them, and add them putting them to the bottom as much as possible
            var largestHeight: CGFloat = 0.0
            let headerRects: [(Int, CGRect)] = sectionGroup.map {
                let width = $1.width
                let height = max(ceil(delegate.collectionView(collectionView, layout: layout, heightForHeaderInSection: $0, givenSectionWidth: width)), 0.0)
                largestHeight = max(largestHeight, height)
                return ($0, CGRect(x: $1.x, y: 0.0, width: width, height: height))
            }
            currentYOffset += largestHeight
            
            for headerRect in headerRects {
                var rect    = headerRect.1
                let height = rect.size.height
                
                if height.isZero {
                    sectionHeaderAttributes.append(nil)
                } else {
                    rect.origin.y = currentYOffset - height
                    
                    let sectionIndexPath = IndexPath(item: 0, section: headerRect.0)
                    let headerAttribute: UICollectionViewLayoutAttributes
                    if let dequeuedAttributes = reusableSectionHeaderAttributes.popLast() {
                        dequeuedAttributes.indexPath = sectionIndexPath
                        headerAttribute = dequeuedAttributes
                    } else {
                        headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: sectionIndexPath)
                        headerAttribute.zIndex = 1
                    }
                    headerAttribute.frame = rect
                    sectionHeaderAttributes.append(headerAttribute)
                }
            }
            
            // If we're laid right against another section's previous footer separator,
            // we can overlap section header separators to avoid a double high separator.
            if let sectionFooterSepAttributes = sectionSeparatorAttributes.last?.last , sectionFooterSepAttributes.frame.maxY == currentYOffset {
                currentYOffset -= separatorVerticalSpacing
            }
            
            // Place in the section heading separators
            let headerSeparatorAttributes: [CollectionViewFormDecorationAttributes] = wantsSectionSeparators ? sectionGroup.map {
                let headerSeparator: CollectionViewFormDecorationAttributes
                let indexPath = IndexPath(item: 0, section: $0.0)
                if let dequeudAttribute = reusableSectionSeparators.popLast() {
                    headerSeparator = dequeudAttribute
                    headerSeparator.indexPath = indexPath
                } else {
                    headerSeparator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorSection, with: indexPath)
                    headerSeparator.zIndex = 2
                }
                headerSeparator.backgroundColor = sectionSeparatorColor
                headerSeparator.frame = CGRect(x: $0.1.x, y: currentYOffset, width: $0.1.width, height: separatorWidth)
                return headerSeparator
                } : []
            
            currentYOffset += separatorVerticalSpacing
            let startOfItems = currentYOffset
            
            // Put each of the section item columns in place.
            var maxSectionHeight: CGFloat = 0.0
            for section in sectionGroup {
                maxSectionHeight = max(maxSectionHeight, processItemsInSection(section.0, atPoint: CGPoint(x: section.1.x, y: startOfItems), withWidth: section.1.width))
            }
            currentYOffset += maxSectionHeight
            
            // Place in the section backgrounds and remaining separators.
            for (sectionGroupIndex, section) in sectionGroup.enumerated() {
                var sideSeparator: CollectionViewFormDecorationAttributes? = nil
                var footerSeparator: CollectionViewFormDecorationAttributes? = nil
                
                let xOrigin = section.1.x
                
                let footerSeparatorFrame = CGRect(x: xOrigin, y: currentYOffset - separatorWidth, width: section.1.width, height: separatorWidth)
                let sideSepFrame = CGRect(x: section.1.width + section.1.x - separatorWidth, y: startOfItems, width: separatorWidth, height: footerSeparatorFrame.minY - startOfItems)
                let sectionBackgroundFrame = CGRect(x: xOrigin, y: startOfItems, width: sideSepFrame.maxX - xOrigin, height: currentYOffset - startOfItems)
                
                if wantsSectionSeparators {
                    let footerSepIndexPath = IndexPath(item: 2, section: section.0)
                    if let dequeudAttribute = reusableSectionSeparators.popLast() {
                        footerSeparator = dequeudAttribute
                        dequeudAttribute.indexPath = footerSepIndexPath
                    } else {
                        footerSeparator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorSection, with: footerSepIndexPath)
                        footerSeparator?.zIndex = 2
                    }
                    footerSeparator?.backgroundColor = sectionSeparatorColor
                    footerSeparator?.frame = footerSeparatorFrame
                    
                    let sideSepIndexPath = IndexPath(item: 1, section: section.0)
                    if let dequeudAttribute = reusableSectionSeparators.popLast() {
                        sideSeparator = dequeudAttribute
                        dequeudAttribute.indexPath = sideSepIndexPath
                    } else {
                        sideSeparator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorSection, with: sideSepIndexPath)
                        sideSeparator?.zIndex = 2
                    }
                    sideSeparator?.backgroundColor = sectionSeparatorColor
                    sideSeparator?.frame = sideSepFrame
                }
                
                if wantsSectionBackgrounds {
                    let sectionBackgroundAttribute: CollectionViewFormDecorationAttributes
                    let sectionBackgroundIndexPath = IndexPath(item: 0, section: section.0)
                    if let dequeuedBackgroundAttribute = reusableSectionBackgroundAttributes.popLast() {
                        dequeuedBackgroundAttribute.indexPath = sectionBackgroundIndexPath
                        sectionBackgroundAttribute = dequeuedBackgroundAttribute
                    } else {
                        sectionBackgroundAttribute = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSectionBackground, with: sectionBackgroundIndexPath)
                        sectionBackgroundAttribute.backgroundColor = layout.sectionColor
                        sectionBackgroundAttribute.zIndex = 0
                    }
                    sectionBackgroundAttribute.frame = sectionBackgroundFrame
                    sectionBackgroundAttributes.append(sectionBackgroundAttribute)
                }
                
                if wantsSectionSeparators, let sideSeparator = sideSeparator, let footerSeparator = footerSeparator  {
                    let zeroBackground = sectionBackgroundFrame.height.isZero
                    let headerSeparator = headerSeparatorAttributes[sectionGroupIndex]
                    
                    sideSeparator.alpha   = sectionBackgroundFrame.maxX >= collectionViewWidth || zeroBackground ? 0.0 : 1.0
                    headerSeparator.alpha = zeroBackground ? 0.0 : 1.0
                    footerSeparator.alpha = zeroBackground ? 0.0 : 1.0
                    sectionSeparatorAttributes.append([headerSeparator, sideSeparator, footerSeparator])
                }
            }
            
            // Place in the footer views
            var largestFooter: CGFloat = 0.0
            for section in sectionGroup {
                let width = section.1.width
                let footerHeight = max(ceil(delegate.collectionView(collectionView, layout: layout, heightForFooterInSection: section.0, givenSectionWidth: width)), 0.0)
                largestFooter = max(footerHeight, largestFooter)
                
                if footerHeight.isZero {
                    sectionFooterAttributes.append(nil)
                } else {
                    let footerIndexPath = IndexPath(item: 0, section: section.0)
                    let footerAttribute: UICollectionViewLayoutAttributes
                    if let dequeuedAttributes = reusableSectionFooterAttributes.popLast() {
                        dequeuedAttributes.indexPath = footerIndexPath
                        footerAttribute = dequeuedAttributes
                    } else {
                        footerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: footerIndexPath)
                        footerAttribute.zIndex = 1
                    }
                    footerAttribute.frame = CGRect(x: section.1.x, y: currentYOffset, width: section.1.width, height: footerHeight)
                    sectionFooterAttributes.append(footerAttribute)
                }
                
                sectionRects.append(CGRect(x: section.1.x, y: startOfHeaders, width: width, height: currentYOffset + footerHeight - startOfHeaders))
            }
            
            currentYOffset += largestFooter
        }
        
        if let globalFooterHeight = delegate.collectionView?(collectionView, heightForGlobalFooterInLayout: layout) , globalFooterHeight > 0.0 {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindGlobalFooter, with: IndexPath(index: 0))
            attribute.frame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewWidth, height: ceil(globalFooterHeight))
            attribute.zIndex = 1
            globalFooterAttribute = attribute
            currentYOffset += ceil(globalFooterHeight)
        } else {
            globalFooterAttribute = nil
        }
    }
    
}
