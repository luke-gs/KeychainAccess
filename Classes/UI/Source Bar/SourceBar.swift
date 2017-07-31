//
//  SourceView.swift
//  MPOLKit
//
//  Created by Rod Brown on 8/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A control for displaying a source picker in MPOL applications.
///
/// Source view provides a soft "glow" on selected items, and can be configured to
/// optimize for light or dark contexts. When compressed the source bar allows scrolling
/// to further elements.
public class SourceBar: UIScrollView {
    
    public enum Axis {
        case vertical
        case horizontal
    }
    
    
    // MARK: - Public properties
    
    public var axis: Axis = .vertical {
        didSet {
            if axis == oldValue { return }
            
            updateContentSizePriorities()
            needsCellReload = true
            setNeedsLayout()
        }
    }
    
    
    /// The items to display. The default is none.
    ///
    /// When there are no items, the source view prefers to compress to zero width
    /// to hide via AutoLayout.
    ///
    /// Setting this property doesn't update the selectedIndex property, except where the
    /// selected index would point to an item that is beyond the length of this array. In
    /// this case, the selected index becomes `nil`. It is recommended you update the
    /// selected index after each time you change the items.
    public var items: [SourceItem] = [] {
        didSet {
            if items == oldValue { return }
            
            if let index = selectedIndex, items.count < index {
                selectedIndex = nil
            }
            
            needsCellReload = true
            setNeedsLayout()
        }
    }
    
    
    /// The selected index. The default is `nil`.
    public var selectedIndex: Int? {
        didSet {
            if selectedIndex != oldValue && highlightedIndex == nil {
                updateCellSelection()
            }
        }
    }
    
    
    /// The background view of the source bar.
    /// 
    /// A source bar’s background view is automatically resized to match the size of the bar.
    /// This view is placed as a subview of the table view behind all cells.
    public var backgroundView: UIView? {
        didSet {
            if backgroundView == oldValue { return }
            
            oldValue?.removeFromSuperview()
            if let newBackgroundView = backgroundView {
                insertSubview(newBackgroundView, at: 0)
                setNeedsLayout()
            }
        }
    }
    
    
    /// The source bar's delegate, conforming to `SourceBarDelegate` protocol.
    ///
    /// Optimally, this would override the delegate and redeclare the conforming protocol type as the
    /// source bar delegate, much like `UITableViewDelegate` extends `UIScrollViewDelegate` also.
    /// This is a language limitation, so we have a separate property.
    public weak var sourceBarDelegate: SourceBarDelegate?
    
    
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    
    // MARK: - Private properties
    
    private var highlightedIndex: Int?
    
    private var dragCancelledHighlight: Bool = false
    
    private var cells: [SourceBarCell] = []
    
    private var needsCellReload: Bool = false
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isAccessibilityElement = false
        accessibilityLabel = NSLocalizedString("Source Bar", bundle: .mpolKit, comment: "Localized Source Bar Component name")
        accessibilityTraits = UIAccessibilityTraitTabBar
        
        updateContentSizePriorities()
        
        indicatorStyle = .white
        
        backgroundColor = #colorLiteral(red: 0.1055394784, green: 0.1170256063, blue: 0.1421703398, alpha: 1)
        
        panGestureRecognizer.addTarget(self, action: #selector(scrollViewPanRecognizeStateDidChange(_:)))
    }
    
    
    // MARK: - Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        backgroundView?.frame = bounds
        
        if needsCellReload == false { return }
        
        var reusableCells = cells
        
        cells = items.map {
            let cell: SourceBarCell
            if reusableCells.isEmpty == false {
                cell = reusableCells.remove(at: 0)
            } else {
                cell = SourceBarCell(frame: .zero)
                cell.addTarget(self, action: #selector(touchDown(in:)), for: .touchDown)
                cell.addTarget(self, action: #selector(touchUp(in:)),   for: .touchUpInside)
                cell.addTarget(self, action: #selector(touchCancelled(in:)), for: [.touchCancel, .touchUpOutside])
                addSubview(cell)
            }
            cell.axis = self.axis
            cell.update(for: $0)
            cell.sizeToFit()
            
            return cell
        }
        
        reusableCells.forEach { $0.removeFromSuperview() }
        
        let cellCount = cells.count
        if cellCount == 0 {
            contentSize = .zero
            accessibilityElements = nil
            return
        }
        
        updateCellSelection()
        
        
        switch axis {
        case .vertical:
            var yOffset: CGFloat = 10.0
            
            cells.forEach {
                var frame = $0.frame
                frame.origin = CGPoint(x: 0.0, y: yOffset)
                $0.frame = frame
                yOffset = frame.maxY
            }
            
            yOffset += 10.0
            
            contentSize = CGSize(width: 64.0, height: yOffset)
        case .horizontal:
            // TODO: Handle RTL at a later date - low priority for now.
            
            var minSpacingBetween: CGFloat = 15.0
            
            if cellCount == 1 {
                minSpacingBetween = 20.0
                
                // We don't need to fuss over the size of the items for horizontal alignment.
                cells.first!.frame.origin = CGPoint(x: minSpacingBetween, y: 0.0)
            } else {
                let allWidths: CGFloat = cells.reduce(0.0) { $0 + $1.frame.width } // TODO: Swift 4 - switch this to +=
                let boundsWidth = bounds.width
                
                let spacingsCount = CGFloat(cellCount + 1)
                
                if boundsWidth > (allWidths + (spacingsCount * minSpacingBetween)) {
                    // Work out enough for even distribution
                    
                    minSpacingBetween = ((boundsWidth - allWidths) / spacingsCount).floored(toScale: traitCollection.currentDisplayScale)
                }
                var origin = CGPoint(x: minSpacingBetween, y: 0.0)
                
                cells.forEach { cell in
                    var frame = cell.frame
                    frame.origin = origin
                    origin.x = frame.maxX + minSpacingBetween
                    cell.frame = frame
                }
            }
            
            contentSize = CGSize(width: cells.last!.frame.maxX + minSpacingBetween, height: 56.0)
        }
        
        // TODO: Update content size
        
        accessibilityElements = cells
    }
    
    public override func touchesShouldCancel(in view: UIView) -> Bool {
        if let cell = view as? SourceBarCell {
            // we override this to mimic the cell selection rules on table view - that is,
            // dragging on highlight clears highlight but doesn't resume selection until touch up
            // we don't do this on the selected cell tho
            dragCancelledHighlight = cells.index(of: cell) != selectedIndex
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = contentSize
        if items.isEmpty {
            switch axis {
            case .vertical:
                size.width = 0.0
            case .horizontal:
                size.height = 0.0
            }
        }
        return size
    }
    
    
    // MARK: - Private methods
    
    private func updateContentSizePriorities() {
        let stretchyAxis: UILayoutConstraintAxis = axis == .vertical ? .vertical : .horizontal
        let hardAxis: UILayoutConstraintAxis     = axis == .vertical ? .horizontal : .vertical
        
        setContentCompressionResistancePriority(UILayoutPriorityDefaultLow,  for: stretchyAxis)
        setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: hardAxis)
        setContentHuggingPriority(UILayoutPriorityFittingSizeLevel, for: stretchyAxis)
        setContentHuggingPriority(UILayoutPriorityRequired - 1,     for: hardAxis)
    }
    
    private func updateCellSelection() {
        cells.enumerated().forEach {
            $0.element.isHighlighted = highlightedIndex == $0.offset
            $0.element.isSelected    = selectedIndex == $0.offset && dragCancelledHighlight == false && (highlightedIndex == nil || highlightedIndex == $0.offset)
        }
    }
    
    @objc private func touchDown(in cell: SourceBarCell) {
        highlightedIndex = cells.index(of: cell)
        updateCellSelection()
    }
    
    @objc private func touchUp(in cell: SourceBarCell) {
        highlightedIndex = nil
        if let cellIndex = cells.index(of: cell) {
            switch items[cellIndex].state {
            case .notLoaded:
                sourceBarDelegate?.sourceBar(self, didRequestToLoadItemAt: cellIndex)
            case .loaded:
                selectedIndex = cellIndex
                sourceBarDelegate?.sourceBar(self, didSelectItemAt: cellIndex)
            default:
                break
            }
        }
        updateCellSelection()
    }
    
    @objc private func touchCancelled(in cell: SourceBarCell) {
        highlightedIndex = nil
        updateCellSelection()
    }
    
    @objc private func scrollViewPanRecognizeStateDidChange(_ recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .ended || recognizer.state == .cancelled) && dragCancelledHighlight {
            // Handle where the pan ended, and we've got a "drag cancelled highlight" pause on highlights. Reset it to off and update selection.
            dragCancelledHighlight = false
            updateCellSelection()
        }
    }
    
}


/// The delegate of a `SourceBar` object should adopt the SourceViewDelegate protocol.
/// The protocol provides callbacks for when the selected item changed.
public protocol SourceBarDelegate: class {
    
    func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int)
    
    func sourceBar(_ bar: SourceBar, didRequestToLoadItemAt index: Int)
    
}
