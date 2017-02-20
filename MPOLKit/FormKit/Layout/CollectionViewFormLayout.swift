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
            if separatorColor == oldValue || sectionRects.count == 0 { return }
            
            var rowSeparators: [IndexPath] = []
            var rowCapacity = 0
            for section in rowSeparatorAttributes {
                rowCapacity += section.count
                if rowCapacity > 0 { rowSeparators.reserveCapacity(rowCapacity) }
                for row in section {
                    row.backgroundColor = separatorColor
                    rowSeparators.append(row.indexPath)
                }
            }
            
            var itemSeparators: [IndexPath] = []
            var itemCapacity = 0
            for section in itemSeparatorAttributes {
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
    
    open var wantsVerticalItemSeparators: Bool = true {
        didSet {
            if wantsVerticalItemSeparators != oldValue {
                invalidateLayout()
            }
        }
    }
    
    open var wantsHorizontalItemSeparators: Bool = true {
        didSet {
            if wantsHorizontalItemSeparators != oldValue {
                invalidateLayout()
            }
        }
    }
    
    open var wantsSectionSeparators: Bool = true {
        didSet {
            if wantsSectionSeparators != oldValue {
                invalidateLayout()
            }
        }
    }
    
    open var wantsSectionBackgrounds: Bool = true {
        didSet {
            if wantsSectionBackgrounds != oldValue {
                invalidateLayout()
            }
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
    
    fileprivate var contentSize:                 CGSize = .zero
    fileprivate var sectionRects:                [CGRect] = []
    fileprivate var globalHeaderAttribute:       UICollectionViewLayoutAttributes?
    fileprivate var globalFooterAttribute:       UICollectionViewLayoutAttributes?
    fileprivate var sectionHeaderAttributes:     [UICollectionViewLayoutAttributes?]  = []
    fileprivate var sectionFooterAttributes:     [UICollectionViewLayoutAttributes?]  = []
    fileprivate var sectionBackgroundAttributes: [CollectionViewFormDecorationAttributes] = []
    fileprivate var itemAttributes:              [[CollectionViewFormItemAttributes]]     = []
    
    fileprivate var sectionSeparatorAttributes:  [[CollectionViewFormDecorationAttributes]] = []
    fileprivate var rowSeparatorAttributes:      [[CollectionViewFormDecorationAttributes]] = []
    fileprivate var itemSeparatorAttributes:     [[CollectionViewFormDecorationAttributes]] = []
    
    fileprivate var previousSectionRowSeparatorCounts: [Int] = []
    fileprivate var previousSectionItemCounts:         [Int] = []
    
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSectionBackground)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorSection)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorRow)
        register(CollectionViewFormDecorationView.self, forDecorationViewOfKind: collectionElementKindSeparatorItem)
    }
    
    
    // MARK: - Layout preparation
    
    open override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegateFormLayout else {
                return
        }
        
        let collectionViewWidth = collectionView.bounds.size.width
        
        let screenScale = (collectionView.window?.screen ?? UIScreen.main).scale
        let singlePixel: CGFloat = 1.0 / screenScale
        let separatorWidth = self.separatorWidth
        let separatorVerticalSpacing = separatorWidth.ceiled(toScale: screenScale) // This value represents a pixel-aligned adjustment to ensure we don't get blurry cells.
        
        let wantsSectionSeparators        = self.wantsSectionSeparators
        let wantsHorizontalItemSeparators = self.wantsHorizontalItemSeparators
        let wantsVerticalItemSeparators   = self.wantsVerticalItemSeparators
        let wantsSectionBackgrounds       = self.wantsSectionBackgrounds
        
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
        
        previousSectionRowSeparatorCounts = rowSeparatorAttributes.map{$0.count}
        previousSectionItemCounts         = itemSeparatorAttributes.map{$0.count}
        
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
        
        let itemLayoutMargins = self.itemLayoutMargins
        
        let itemSeparatorColor = self.itemSeparatorColor
        let sectionSeparatorColor = self.sectionSeparatorColor
        
        // function to process a section's items. ensure that insets are accounted for.
        func processItemsInSection(_ section: Int, atPoint point: CGPoint, withWidth width: CGFloat) -> CGFloat { // Returns height of section items
            
            let sectionDistribution: CollectionViewFormLayout.Distribution
            if let foundDistribution = delegate.collectionView?(collectionView, layout: self, distributionForSection: section) , foundDistribution != .automatic {
                sectionDistribution = foundDistribution
            } else {
                sectionDistribution = self.distribution
            }
            
            var currentYOrigin = point.y
            
            let insets = delegate.collectionView(collectionView, layout: self, insetForSection: section, givenSectionWidth: width)
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
                                    separator.alpha = separatorFrame.maxX < collectionViewWidth && delegate.collectionView!(collectionView, layout: self, shouldDisplayHorizontalSeparatorForItemAt: indexPath) ? 1.0 : 0.0
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
                            separator.isHidden = delegateSupportsHidingVerticalSeparators && (delegate.collectionView!(collectionView, layout: self, shouldDisplayVerticalSeparatorBelowItemAt: rowItems.last!.ip) == false)
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
        
        for sectionGroup: [(Int, (x: CGFloat, width: CGFloat))] in sectionGroups {
            // process each section group
            let startOfHeaders = currentYOffset
            
            // First get headers, work out the taller of them, and add them putting them to the bottom as much as possible
            var largestHeight: CGFloat = 0.0
            let headerRects: [(Int, CGRect)] = sectionGroup.map {
                let width = $1.width
                let height = max(ceil(delegate.collectionView(collectionView, layout: self, heightForHeaderInSection: $0, givenSectionWidth: width)), 0.0)
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
                        sectionBackgroundAttribute.backgroundColor = sectionColor
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
                    footerAttribute.frame = CGRect(x: section.1.x, y: currentYOffset, width: section.1.width, height: footerHeight)
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
        
        self.contentSize = CGSize(width: collectionViewWidth, height: currentYOffset)
    }
    
    // MARK: - Layout attribute fetching
    
    open override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if globalHeaderAttribute?.frame.intersects(rect) ?? false {
            attributes.append(globalHeaderAttribute!)
        }
        if globalFooterAttribute?.frame.intersects(rect) ?? false {
            attributes.append(globalFooterAttribute!)
        }
        
        for (sectionIndex, sectionRect) in sectionRects.enumerated() {
            if sectionRect.minY > rect.maxY { break }
            if sectionRect.intersects(rect) == false { continue }
            
            if let sectionHeaderItem = sectionHeaderAttributes[sectionIndex]
                , sectionHeaderItem.frame.intersects(rect) {
                attributes.append(sectionHeaderItem)
            }
            
            let sectionBackgroundItem  = sectionBackgroundAttributes[sectionIndex]
            let sectionBackgroundFrame = sectionBackgroundItem.frame
            if sectionBackgroundFrame.minY > rect.maxY { break }
            
            if wantsSectionSeparators {
                for separator in sectionSeparatorAttributes[sectionIndex] {
                    let frame = separator.frame
                    if frame.minY > rect.maxY { break }
                    if frame.intersects(rect) {
                        attributes.append(separator)
                    }
                }
            }
            
            if sectionBackgroundFrame.intersects(rect) {
                attributes.append(sectionBackgroundItem)
                
                
                let itemSeparators = itemSeparatorAttributes[sectionIndex]
                for (itemIndex, item) in itemAttributes[sectionIndex].enumerated() {
                    let frame = item.frame
                    if frame.minY > rect.maxY { break }
                    if frame.intersects(rect) {
                        attributes.append(item)
                        if wantsVerticalItemSeparators {
                            attributes.append(itemSeparators[itemIndex])
                        }
                    }
                }
                
                if wantsHorizontalItemSeparators {
                    for row in rowSeparatorAttributes[sectionIndex] {
                        let frame = row.frame
                        if frame.minY > rect.maxY { break }
                        if frame.intersects(rect) {
                            attributes.append(row)
                        }
                    }
                }
            }
            
            if let sectionFooterItem = sectionFooterAttributes[sectionIndex] , sectionFooterItem.frame.intersects(rect) {
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
            if indexPath == globalHeaderAttribute?.indexPath { return globalHeaderAttribute! }
        case collectionElementKindGlobalFooter:
            if indexPath == globalFooterAttribute?.indexPath { return globalFooterAttribute! }
        default:
            break
        }
        
        return nil
    }
    
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: CollectionViewFormDecorationAttributes?
        
        switch elementKind {
        case collectionElementKindSectionBackground: attributes = sectionBackgroundAttributes[ifExists: indexPath.section]
        case collectionElementKindSeparatorSection:  attributes = sectionSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        case collectionElementKindSeparatorRow:      attributes = rowSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        case collectionElementKindSeparatorItem:     attributes = itemSeparatorAttributes[ifExists: indexPath.section]?[ifExists: indexPath.row]
        default:                                     attributes = nil
        }
        
        return attributes ?? CollectionViewFormDecorationAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
    }
    
    
    // MARK: - Invalidation
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let currentContentWidth = fabs(contentSize.width)
        let newWidth = fabs(newBounds.size.width)
        
        // Don't perform an update if there is no width, or if there is no content.
        if newWidth == currentContentWidth || (sectionRects.last?.maxY.isZero ?? true) { return false }
        
        if UIView.areAnimationsEnabled {
            let animationDuration = UIView.inheritedAnimationDuration
            if animationDuration.isZero { return true }
            
            let collectionView = self.collectionView!
            DispatchQueue.main.async {
                var firstCellIndexPath: IndexPath? = nil
                
                for attribute in self.layoutAttributesForElements(in: collectionView.bounds)! {
                    if attribute.representedElementCategory != .cell { continue }
                    firstCellIndexPath = attribute.indexPath
                    break
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
                    insertedItemSeparators! += (0..<collectionView!.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .delete:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedSections!.append(section)
                    deletedItemSeparators! += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                case .reload:
                    let section = item.indexPathBeforeUpdate!.section
                    deletedItemSeparators! += (0..<previousSectionItemCounts[section]).map { IndexPath(item: $0, section: section) }
                    insertedItemSeparators! += (0..<collectionView!.numberOfItems(inSection: section)).map { IndexPath(item: $0, section: section) }
                case .move:
                    let oldSection = item.indexPathBeforeUpdate!.section
                    deletedSections!.append(oldSection)
                    deletedItemSeparators! += (0..<previousSectionItemCounts[oldSection]).map { IndexPath(item: $0, section: oldSection) }
                    let newSection = item.indexPathAfterUpdate!.section
                    insertedSections!.append(newSection)
                    insertedItemSeparators! += (0..<collectionView!.numberOfItems(inSection: newSection)).map { IndexPath(item: $0, section: newSection) }
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
        
        if wantsHorizontalItemSeparators {
            for (index, section) in rowSeparatorAttributes.enumerated() {
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
    }
    
    open override func finalizeCollectionViewUpdates() {
        insertedItemSeparators     = nil
        deletedItemSeparators      = nil
        insertedRowSeparators      = nil
        deletedRowSeparators       = nil
        insertedSections           = nil
        deletedSections            = nil
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
            if wantsSectionSeparators {
                insertedSections?.forEach {
                    allSectionSeparators.append(IndexPath(item: 0, section: $0))
                    allSectionSeparators.append(IndexPath(item: 1, section: $0))
                    allSectionSeparators.append(IndexPath(item: 2, section: $0))
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
            if wantsHorizontalItemSeparators {
                deletedSections?.forEach {
                    allSectionSeparators.append(IndexPath(item: 0, section: $0))
                    allSectionSeparators.append(IndexPath(item: 1, section: $0))
                    allSectionSeparators.append(IndexPath(item: 2, section: $0))
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
    
    
    /// Asks the delegate if the layout should display a horizontal separator on the left edge of the item.
    /// If unimplemented, the default is `true`.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    /// - Returns:          A boolean value indicating whether a horizontal separator should be displayed.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, shouldDisplayHorizontalSeparatorForItemAt indexPath: IndexPath) -> Bool
    
    
    /// Asks the delegate if the layout should display a vertical separator on the bottom edge of the item.
    /// If implemented, the layout requests this passing the final item in a row. If unimplemented, the
    /// default is `true`.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view displaying the form layout.
    ///   - layout:         The layout object requesting the information.
    ///   - indexPath:      The indexPath for the item.
    /// - Returns:          A boolean value indicating whether a vertical separator should be displayed.
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: CollectionViewFormLayout, shouldDisplayVerticalSeparatorBelowItemAt indexPath: IndexPath) -> Bool
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
