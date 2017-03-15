//
//  CollectionViewFormMPOLLayout.swift
//  MPOLKit
//
//  Created by Rod Brown on 21/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit


@objc public protocol CollectionViewDelegateMPOLLayout: CollectionViewDelegateFormLayout {
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormMPOLLayout, separatorStyleForItemAt indexPath: IndexPath) -> CollectionViewFormMPOLLayout.SeparatorStyle
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormMPOLLayout, wantsInsetHeaderInSection section: Int) -> Bool
    
}



/// A FormKit collection view layout for MPOL style collections.
///
/// `CollectionViewFormMPOLLayout` supports MPOL layouts where section header views
/// overlap the top layout margins of a cell, and places item separators below each
/// cell with an specified separator style.
///
/// MPOL layouts automatically handle right-to-left languages. All delegate methods
/// and properties should return insets and details in left-to-right values, which
/// the layout will transform when required.
public class CollectionViewFormMPOLLayout: CollectionViewFormLayout {
    
    @objc(CollectionViewFormMPOLSeparatorStyle) public enum SeparatorStyle: Int {
        case automatic
        
        case indented
        
        case fullWidth
        
        case hidden
    }
    
    public var separatorStyle: SeparatorStyle = .indented {
        didSet {
            if separatorStyle == .automatic {
                separatorStyle = .indented
            }
            
            if separatorStyle != oldValue {
                invalidateLayout()
            }
        }
    }
    
    public var rowLeadingSeparatorsShouldAlwaysIndent: Bool = true {
        didSet {
            if rowLeadingSeparatorsShouldAlwaysIndent != oldValue {
                invalidateLayout()
            }
        }
    }
    
    public var wantsInsetHeaders: Bool = true {
        didSet {
            if wantsInsetHeaders != oldValue {
                invalidateLayout()
            }
        }
    }
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else { return }
        
        let isRTL: Bool
        if #available(iOS 10, *) {
            isRTL = collectionView.effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRTL = UIView.userInterfaceLayoutDirection(for: collectionView.semanticContentAttribute) == .rightToLeft
        }
        
        let delegateSpecifiesSeparatorStyle = delegate.responds(to: #selector(CollectionViewDelegateMPOLLayout.collectionView(_:layout:separatorStyleForItemAt:)))
        
        let collectionViewWidth = collectionView.bounds.width
        
        let screenScale = (collectionView.window?.screen ?? .main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        let separatorWidth = self.separatorWidth
        let separatorVerticalSpacing = separatorWidth.ceiled(toScale: screenScale) // This value represents a pixel-aligned adjustment to ensure we don't get blurry cells.
        
        var reusableSectionHeaderAttributes: [CollectionViewFormMPOLHeaderAttributes] = sectionHeaderAttributes.flatMap{$0 as? CollectionViewFormMPOLHeaderAttributes}
        var reusableSectionFooterAttributes: [UICollectionViewLayoutAttributes] = sectionFooterAttributes.flatMap{$0}
        
        var reusableSectionItemBackgroundAttributes = sectionItemBackgroundAttributes
        var reusableItemAttributes: [CollectionViewFormItemAttributes]       = itemAttributes.flatMap { $0 }
        var reusableItemSeparators: [CollectionViewFormDecorationAttributes] = itemSeparatorAttributes.flatMap { $0 }
        
        sectionRects.removeAll(keepingCapacity: true)
        itemAttributes.removeAll(keepingCapacity: true)
        sectionHeaderAttributes.removeAll(keepingCapacity: true)
        sectionFooterAttributes.removeAll(keepingCapacity: true)
        sectionItemBackgroundAttributes.removeAll(keepingCapacity: true)
        itemSeparatorAttributes.removeAll(keepingCapacity: true)
        
        let numberOfSections = collectionView.numberOfSections
        sectionRects.reserveCapacity(numberOfSections)
        itemAttributes.reserveCapacity(numberOfSections)
        sectionHeaderAttributes.reserveCapacity(numberOfSections)
        sectionFooterAttributes.reserveCapacity(numberOfSections)
        sectionItemBackgroundAttributes.reserveCapacity(numberOfSections)
        itemSeparatorAttributes.reserveCapacity(numberOfSections)
        
        let itemLayoutMargins     = self.itemLayoutMargins
        let itemSeparatorColor    = self.itemSeparatorColor
        let defaultSeparatorStyle = separatorStyle
        
        // function to process a section's items. ensure that insets are accounted for.
        func processItemsInSection(_ section: Int, atPoint point: CGPoint, withWidth width: CGFloat, insets: UIEdgeInsets) -> CGFloat { // Returns height of section items
            
            let sectionDistribution: CollectionViewFormLayout.Distribution
            if let foundDistribution = delegate.collectionView?(collectionView, layout: self, distributionForSection: section) , foundDistribution != .automatic {
                sectionDistribution = foundDistribution
            } else {
                sectionDistribution = self.distribution
            }
            
            var currentYOrigin = point.y
            
            let sectionLeftInset  = insets.left.rounded(toScale: screenScale)
            let sectionRightInset = insets.right.rounded(toScale: screenScale)
            
            let firstItemLeftWidthInset = sectionLeftInset.isZero ? itemLayoutMargins.left : 0.0
            let lastItemRightWidthInset = sectionRightInset.isZero ? itemLayoutMargins.right : 0.0
            
            let sectionWidth: CGFloat = width - sectionLeftInset - sectionRightInset
            
            let maximumAllowedWidth: CGFloat = sectionWidth - firstItemLeftWidthInset - lastItemRightWidthInset
            
            var itemMinWidths: [(IndexPath, CGFloat)] = (0..<collectionView.numberOfItems(inSection: section)).map {
                // Create a tuple representing the index path for this item in the section. Provide the minimum width, at maximum of either zero, or the minimum of width and the section width. This ensures an item width that can fit and will never be below zero.
                let indexPath = IndexPath(item: $0, section: section)
                let width: CGFloat = max(min((delegate.collectionView(collectionView, layout: self, minimumContentWidthForItemAt: indexPath, givenSectionWidth: width, edgeInsets: insets)).floored(toScale: screenScale), maximumAllowedWidth), 0.0)
                return (indexPath, width)
            }
            
            let sectionItemCount = itemMinWidths.count
            
            var sectionItemAttributes: [CollectionViewFormItemAttributes] = []
            sectionItemAttributes.reserveCapacity(sectionItemCount)
            
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
                            
                            let itemMinHeight = ceil(delegate.collectionView(collectionView, layout: self, minimumContentHeightForItemAt: indexPath, givenItemContentWidth: newContentWidth))
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
                        
                        var rowHasSeparator = false
                        
                        for (rowIndex, item) in rowItems.enumerated() {
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
                            itemAttribute.frame = isRTL ? frame.rtlFlipped(forWidth: collectionViewWidth) : frame
                            itemAttribute.layoutMargins = isRTL ? item.margins.horizontallyFlipped() : item.margins
                            
                            sectionItemAttributes.append(itemAttribute)
                            
                            let separator: CollectionViewFormDecorationAttributes
                            if let dequeuedAttribute = reusableItemSeparators.popLast() {
                                dequeuedAttribute.indexPath = indexPath
                                separator = dequeuedAttribute
                            } else {
                                separator = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSeparatorItem, with: indexPath)
                                separator.zIndex = 2
                            }
                            separator.backgroundColor = itemSeparatorColor
                            
                            var separatorStyle: SeparatorStyle
                            if delegateSpecifiesSeparatorStyle {
                                let style = (delegate as! CollectionViewDelegateMPOLLayout).collectionView!(collectionView, layout: self, separatorStyleForItemAt: indexPath)
                                separatorStyle = style == .automatic ? defaultSeparatorStyle : style
                            } else {
                                separatorStyle = defaultSeparatorStyle
                            }
                            
                            if separatorStyle == .fullWidth && rowIndex == 0 && rowLeadingSeparatorsShouldAlwaysIndent {
                                separatorStyle = .indented
                            }
                            
                            var separatorFrame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: separatorWidth)
                            if separatorStyle == .indented || (separatorStyle == .hidden && (defaultSeparatorStyle == .indented || rowIndex == 0 && rowLeadingSeparatorsShouldAlwaysIndent)) {
                                separatorFrame.origin.x   += item.margins.left
                                separatorFrame.size.width -= item.margins.left
                            }
                            separator.frame = isRTL ? separatorFrame.rtlFlipped(forWidth: collectionViewWidth) : separatorFrame
                            separator.isHidden = separatorStyle == .hidden
                            
                            if separatorStyle != .hidden {
                                rowHasSeparator = true
                            }
                            
                            sectionItemSepAttributes.append(separator)
                        }
                        
                        currentYOrigin += minHeight
                        if rowHasSeparator {
                            currentYOrigin += separatorVerticalSpacing
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
            
            return currentYOrigin + max(0.0, round(insets.bottom)) - point.y
        }
        
        var currentYOffset: CGFloat = 0.0
        
        if let globalHeaderHeight = delegate.collectionView?(collectionView, heightForGlobalHeaderInLayout: self) , globalHeaderHeight > 0.0 {
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
            let widths = (0..<numberOfSections).map {($0, min(floor(delegate.collectionView!(collectionView, layout: self, minimumWidthForSection: $0)), collectionViewWidth)) }
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
        
        
        let defaultWantsSectionHeaderInsets = wantsInsetHeaders
        
        for sectionGroup: [(Int, (x: CGFloat, width: CGFloat))] in sectionGroups {
            
            var sectionIndentAdded: Bool = false
            
            // process each section group
            let startOfHeaders = currentYOffset
            
            // First get headers, work out the taller of them, and add them putting them to the bottom as much as possible
            var largestHeight: CGFloat = 0.0
            let headerRects: [(Int, CGRect, UIEdgeInsets)] = sectionGroup.map {
                let width = $1.width
                let height = max(ceil(delegate.collectionView(collectionView, layout: self, heightForHeaderInSection: $0, givenSectionWidth: width)), 0.0)
                largestHeight = max(largestHeight, height)
                let edgeInsets = delegate.collectionView(collectionView, layout: self, insetForSection: $0, givenSectionWidth: width)
                return ($0, CGRect(x: $1.x, y: 0.0, width: width, height: height), edgeInsets)
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
                    let headerAttribute: CollectionViewFormMPOLHeaderAttributes
                    if let dequeuedAttributes = reusableSectionHeaderAttributes.popLast() {
                        dequeuedAttributes.indexPath = sectionIndexPath
                        headerAttribute = dequeuedAttributes
                    } else {
                        headerAttribute = CollectionViewFormMPOLHeaderAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: sectionIndexPath)
                        headerAttribute.zIndex = 1
                    }
                    
                    var sectionInset = headerRect.2.left
                    if sectionInset.isZero {
                       sectionInset = itemLayoutMargins.left
                    }
                    
                    headerAttribute.leadingMargin = sectionInset
                    headerAttribute.separatorWidth = separatorWidth
                    
                    let wantsInsetSectionHeader = (delegate as? CollectionViewDelegateMPOLLayout)?.collectionView?(collectionView, layout: self, wantsInsetHeaderInSection: sectionIndexPath.section) ?? defaultWantsSectionHeaderInsets
                    if wantsInsetSectionHeader {
                        if sectionIndentAdded == false {
                            currentYOffset += separatorVerticalSpacing
                            sectionIndentAdded = true
                        }
                        
                        rect.size.height += separatorVerticalSpacing
                        
                        headerAttribute.itemPosition = rect.size.height
                        rect.size.height += itemLayoutMargins.top
                    }
                    headerAttribute.frame = isRTL ? rect.rtlFlipped(forWidth: collectionViewWidth) : rect
                    sectionHeaderAttributes.append(headerAttribute)
                }
            }
            
            let startOfItems = currentYOffset
            
            // Put each of the section item columns in place.
            var maxSectionHeight: CGFloat = 0.0
            for (rowIndex, section) in sectionGroup.enumerated() {
                maxSectionHeight = max(maxSectionHeight, processItemsInSection(section.0, atPoint: CGPoint(x: section.1.x, y: startOfItems), withWidth: section.1.width, insets: headerRects[rowIndex].2))
            }
            if maxSectionHeight == 0.0 && sectionIndentAdded {
                maxSectionHeight += itemLayoutMargins.top.ceiled(toScale: screenScale)
            }
            currentYOffset += maxSectionHeight
            
            // Place in the section item backgrounds and remaining separators.
            for section in sectionGroup {
                let sectionItemBackgroundAttribute: CollectionViewFormDecorationAttributes
                let sectionItemBackgroundIndexPath = IndexPath(item: 0, section: section.0)
                if let dequeuedBackgroundAttribute = reusableSectionItemBackgroundAttributes.popLast() {
                    dequeuedBackgroundAttribute.indexPath = sectionItemBackgroundIndexPath
                    sectionItemBackgroundAttribute = dequeuedBackgroundAttribute
                } else {
                    sectionItemBackgroundAttribute = CollectionViewFormDecorationAttributes(forDecorationViewOfKind: collectionElementKindSectionItemBackground, with: sectionItemBackgroundIndexPath)
                    sectionItemBackgroundAttribute.zIndex = 0
                }
                sectionItemBackgroundAttribute.backgroundColor = .clear
                
                let xOrigin = section.1.x
                
                let footerSeparatorFrame = CGRect(x: xOrigin, y: currentYOffset - separatorWidth, width: section.1.width, height: separatorWidth)
                let sideSepFrame = CGRect(x: section.1.width + section.1.x - separatorWidth, y: startOfItems, width: separatorWidth, height: footerSeparatorFrame.minY - startOfItems)
                let backgroundFrame = CGRect(x: xOrigin, y: startOfItems, width: sideSepFrame.maxX - xOrigin, height: currentYOffset - startOfItems)
                sectionItemBackgroundAttribute.frame = isRTL ? backgroundFrame.rtlFlipped(forWidth: collectionViewWidth) : backgroundFrame
                
                sectionItemBackgroundAttributes.append(sectionItemBackgroundAttribute)
            }
            
            // Place in the footer views
            var largestFooter: CGFloat = 0.0
            for section in sectionGroup {
                let width = section.1.width
                let footerHeight = max(ceil(delegate.collectionView(collectionView, layout: self, heightForFooterInSection: section.0, givenSectionWidth: width)), 0.0)
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
                    let footerFrame = CGRect(x: section.1.x, y: currentYOffset, width: section.1.width, height: footerHeight)
                    footerAttribute.frame = isRTL ? footerFrame.rtlFlipped(forWidth: collectionViewWidth) : footerFrame
                    sectionFooterAttributes.append(footerAttribute)
                }
                
                sectionRects.append(CGRect(x: section.1.x, y: startOfHeaders, width: width, height: currentYOffset + footerHeight - startOfHeaders))
            }
            
            currentYOffset += largestFooter
        }
        
        if let globalFooterHeight = delegate.collectionView?(collectionView, heightForGlobalFooterInLayout: self) , globalFooterHeight > 0.0 {
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: collectionElementKindGlobalFooter, with: IndexPath(index: 0))
            attribute.frame = CGRect(x: 0.0, y: currentYOffset, width: collectionViewWidth, height: ceil(globalFooterHeight))
            attribute.zIndex = 1
            globalFooterAttribute = attribute
            currentYOffset += ceil(globalFooterHeight)
        } else {
            globalFooterAttribute = nil
        }
        
        contentSize = CGSize(width: collectionViewWidth, height: currentYOffset)
    }
    
}



