//
//  TabStripView.swift
//  MPOLKit
//
//  Created by Rod Brown on 1/5/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

fileprivate let defaultSelectionBarHeight: CGFloat = 2.0
fileprivate let minItemPadding: CGFloat = 30.0


public protocol TabStripViewDelegate: class {
    
    func tabStripView(_ tabStripView: TabStripView, didSelectItemAt index: Int)
    
}


/// A view for displaying an iOS style tab bar in a navigation bar.
open class TabStripView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Public properties
    
    
    /// The items to display in the view.
    open var items: [AnyHashable] = [] {
        didSet {
            if items == oldValue { return }
            
            recalculateCellWidths()
            collectionView.reloadData()
        }
    }
    
    
    /// The index of the current selected item.
    ///
    /// The default is `nil`. Setting this updates the view without animation.
    open var selectedItemIndex: Int? {
        get { return _selectedItemIndex }
        set { setSelectedItemIndex(newValue, animated: false) }
    }
    
    
    /// Selects a new item in the tab with an optional animation.
    ///
    /// - Parameters:
    ///   - newIndex: The new index, or `nil`.
    ///   - animated: A boolean value indicating whether the update should be animated.
    open func setSelectedItemIndex(_ newIndex: Int?, animated: Bool) {
        if _selectedItemIndex == newIndex { return }
        
        _selectedItemIndex = newIndex
        
        if let newValue = newIndex {
            collectionView.selectItem(at: IndexPath(item: newValue, section: 0 ), animated: animated, scrollPosition: .centeredHorizontally)
        } else {
            collectionView.selectItem(at: nil, animated: animated, scrollPosition: [])
        }
    }
    
    
    /// The delegate for the bar.
    open weak var delegate: TabStripViewDelegate?
    
    
    /// The tint color for unselected items.
    /// 
    /// The default is white with an alpha channel of 0.5.
    open var unselectedItemTintColor: UIColor = #colorLiteral(red: 0.9999160171, green: 1, blue: 0.9998849034, alpha: 0.5) {
        didSet {
            if unselectedItemTintColor == oldValue { return }
            
            for case let cell as TabStripViewCell in collectionView.subviews {
                cell.unselectedItemTintColor = unselectedItemTintColor
            }
        }
    }
    
    
    /// The height for the selection bar beneath the item. The default is `2.0`.
    public var selectionBarHeight: CGFloat = defaultSelectionBarHeight {
        didSet {
            if selectionBarHeight ==~ oldValue { return }
            
            invalidateIntrinsicContentSize()
            
            for case let cell as TabStripViewCell in collectionView.subviews {
                cell.selectionBarHeight = selectionBarHeight
            }
        }
    }
    
    
    /// The font appearance for text items in the bar.
    public var textFont: UIFont = .systemFont(ofSize: 14.0, weight: UIFont.Weight.semibold) {
        didSet {
            if textFont == oldValue { return }
            
            for case let cell as TabStripViewTextCell in collectionView.subviews {
                cell.textLabel.font = textFont
            }
            
            recalculateCellWidths()
        }
    }
    
    
    // MARK: - Property overrides
    
    open override var bounds: CGRect {
        didSet {
            if bounds.width !=~ oldValue.width {
                recalculateCellWidths()
            }
            
            if bounds.height !=~ oldValue.height {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    open override var frame: CGRect {
        didSet {
            if frame.width !=~ oldValue.width {
                recalculateCellWidths()
            }
            
            if frame.height !=~ oldValue.height {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: intrinsicWidth, height: 38.0 + selectionBarHeight)
    }
    
    
    // MARK: - Private properties
    
    private let layout: UICollectionViewFlowLayout
    
    private let collectionView: UICollectionView
    
    private var _selectedItemIndex: Int?
    
    private var intrinsicWidth: CGFloat = 0.0 {
        didSet {
            if intrinsicWidth !=~ oldValue {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private var cachedCellWidths: [CGFloat] = [] {
        didSet {
            if cachedCellWidths != oldValue {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    private var cellWidthUpdatePartOfInvalidation: Bool = false
    
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        accessibilityTraits |= UIAccessibilityTraitTabBar
        
        collectionView.frame = bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.backgroundColor = .clear
        collectionView.indicatorStyle  = .white
        collectionView.register(TabStripViewImageCell.self)
        collectionView.register(TabStripViewTextCell.self)
        addSubview(collectionView)
    }
    
    
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TabStripViewCell
        
        switch items[indexPath.item] {
        case let image as UIImage:
            let imageCell = collectionView.dequeueReusableCell(of: TabStripViewImageCell.self, for: indexPath)
            imageCell.imageView.image = image
            cell = imageCell
        case let title as String:
            let textCell = collectionView.dequeueReusableCell(of: TabStripViewTextCell.self, for: indexPath)
            textCell.textLabel.text = title
            textCell.textLabel.font = textFont
            cell = textCell
        default:
            fatalError("TabStripView only supports Strings and Images.")
        }
        
        cell.unselectedItemTintColor = unselectedItemTintColor
        cell.selectionBarHeight      = selectionBarHeight
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return _selectedItemIndex != indexPath.item
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _selectedItemIndex = indexPath.item
        delegate?.tabStripView(self, didSelectItemAt: indexPath.item)
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cachedCellWidths[indexPath.item], height: bounds.height)
    }
    
    
    // MARK: - Overrides
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.currentDisplayScale ?? UIScreen.main.scale !=~ traitCollection.currentDisplayScale {
            recalculateCellWidths()
        }
    }
    
    
    // MARK: - Private methods
    
    private func recalculateCellWidths() {
        let itemCount = items.count
        
        if itemCount == 0 {
            intrinsicWidth = 0.0
            cachedCellWidths = []
            return
        }
        
        let fontAttribute = [NSAttributedStringKey.font: textFont]
        let scale = traitCollection.currentDisplayScale
        
        var maxIndividualWidth: CGFloat = 0.0
        var combinedMinWidth: CGFloat = 0.0
        
        var minWidths: [CGFloat] = items.map {
            let width: CGFloat
            
            switch $0 {
            case let image as UIImage: width = image.size.width + minItemPadding
            case let text as NSString: width = text.size(withAttributes: fontAttribute).width.ceiled(toScale: scale) + minItemPadding
            default: fatalError("TabStripView only supports Strings and Images.")
            }
            
            maxIndividualWidth = max(width, maxIndividualWidth)
            combinedMinWidth += width
            return width
        }
        
        
        let viewWidth = bounds.width
        let itemCountFloat = CGFloat(itemCount)
        let minForEqualSize = itemCountFloat * maxIndividualWidth
        
        if viewWidth >=~ minForEqualSize {
            // Can fit all with equal size. 
            
            let equalPortion = (viewWidth / itemCountFloat).floored(toScale: scale)
            var newWidths = Array<CGFloat>(repeating: equalPortion, count: itemCount)
            
            let remainder = viewWidth - (equalPortion * itemCountFloat)
            if remainder >~ 0.0 {
                newWidths[0] += remainder
            }
            
            cachedCellWidths = newWidths
        } else {
            if viewWidth > combinedMinWidth {
                // Need to scale to fill.
                let leftOverSpace = viewWidth - combinedMinWidth
                let extraPerItem = (leftOverSpace / itemCountFloat).floored(toScale: scale)
                
                for i in minWidths.indices {
                    minWidths[i] += extraPerItem
                }
                
                let leftOverRemainder = leftOverSpace - (extraPerItem * itemCountFloat)
                minWidths[0] += leftOverRemainder
            }
            
            cachedCellWidths = minWidths
        }
        
        intrinsicWidth = minForEqualSize
    }
    
}


fileprivate class TabStripViewCell: UICollectionViewCell, DefaultReusable {
    
    var itemView: UIView {
        MPLRequiresConcreteImplementation()
    }
    
    var unselectedItemTintColor: UIColor? {
        didSet {
            if isSelected || isHighlighted { return }
            updateSelectionHighlight()
        }
    }
    
    var selectionBarHeight: CGFloat = defaultSelectionBarHeight {
        didSet {
            contentView.layoutMargins.bottom = selectionBarHeight
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected == oldValue { return }
            updateSelectionHighlight()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted == oldValue { return }
            updateSelectionHighlight()
        }
    }
    
    
    private let selectionBar = UIView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitButton
        
        let contentView = self.contentView
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: selectionBarHeight, right: 0.0)
        
        selectionBar.translatesAutoresizingMaskIntoConstraints = false
        selectionBar.backgroundColor = tintColor
        selectionBar.alpha = 0.0
        contentView.addSubview(selectionBar)
        
        itemView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemView)
        
        let centerYConstraint: NSLayoutConstraint
        if #available(iOS 11, *) {
            // centerYWithinMargins does not work properly in iOS 11 GM, causes item to not be visible :(
            centerYConstraint = NSLayoutConstraint(item: itemView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, constant: -selectionBarHeight/2)
        } else {
            centerYConstraint = NSLayoutConstraint(item: itemView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins)
        }

        NSLayoutConstraint.activate([
            centerYConstraint,
            NSLayoutConstraint(item: itemView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerXWithinMargins),
            NSLayoutConstraint(item: itemView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: itemView, attribute: .top,     relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .top),

            NSLayoutConstraint(item: selectionBar, attribute: .leading,  relatedBy: .equal, toItem: contentView, attribute: .leading),
            NSLayoutConstraint(item: selectionBar, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing),
            NSLayoutConstraint(item: selectionBar, attribute: .bottom,   relatedBy: .equal, toItem: contentView, attribute: .bottom),
            NSLayoutConstraint(item: selectionBar, attribute: .top,      relatedBy: .equal, toItem: contentView, attribute: .bottomMargin)
        ])
        
        updateSelectionHighlight()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        selectionBar.backgroundColor = tintColor
        updateSelectionHighlight()
    }
    
    func updateSelectionHighlight() {
        let isSelected    = self.isSelected
        let isHighlighted = self.isHighlighted
        
        itemView.alpha     = isHighlighted ? 0.5 : 1.0
        selectionBar.alpha = isHighlighted ? 0.5 : isSelected ? 1.0 : 0.0
        itemView.tintColor = isHighlighted || isSelected ? nil : unselectedItemTintColor
    }
    
}

fileprivate class TabStripViewImageCell: TabStripViewCell {
    
    let imageView = UIImageView(frame: .zero)
    
    override var itemView: UIView { return imageView }
    
    override var accessibilityLabel: String? {
        get { return super.accessibilityLabel ?? imageView.image?.accessibilityLabel }
        set { super.accessibilityLabel = newValue }
    }
    
}

fileprivate class TabStripViewTextCell: TabStripViewCell {
    
    let textLabel = UILabel(frame: .zero)
    
    override var itemView: UIView { return textLabel }
    
    override func updateSelectionHighlight() {
        super.updateSelectionHighlight()
        
        textLabel.textColor = isHighlighted || isSelected ? tintColor : unselectedItemTintColor
    }
    
    override var accessibilityLabel: String? {
        get { return super.accessibilityLabel ?? textLabel.accessibilityLabel }
        set { super.accessibilityLabel = newValue }
    }
    
}
