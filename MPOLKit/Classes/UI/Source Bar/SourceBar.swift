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
    
    
    /// The style options available on source bars.
    public enum Style {
        /// A light style. This appearance is optimized for display over lighter backgrounds.
        case light
        /// A dark style. This appearance is optimized for display over darker backgrounds.
        case dark
    }
    
    
    /// The currenty appearnace style. The default is `.dark`.
    public var style: Style = .dark {
        didSet {
            if style == oldValue { return }
            
            indicatorStyle = style == .dark ? .white : .black
            
            if _cells.count == items.count {
                zip(items, _cells).forEach { (element: (item: SourceItem, cell: SourceBarCell)) in
                    element.cell.update(for: element.item, withStyle: style)
                }
            } else {
                _needsCellReload = true
                setNeedsLayout()
            }
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
                _selectedIndex = nil
            }
            
            let oldCount = oldValue.count
            let newCount = items.count
            
            if oldCount != newCount {
                contentSize = CGSize(width: 64.0, height: CGFloat(items.count) * 77.0 + 20.0)
                
                if (oldCount == 0) != (newCount == 0) {
                    invalidateIntrinsicContentSize()
                }
            }
            
            _needsCellReload = true
            setNeedsLayout()
        }
    }
    
    
    /// The selected index. The default is `nil`.
    public var selectedIndex: Int? {
        get {
            return _selectedIndex
        }
        set {
            if _selectedIndex == newValue { return }
            
            _selectedIndex = newValue
            
            if _highlightedIndex == nil {
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
    
    
    /// A public declaration of the source bar's delegate, conforming to `SourceBarDelegate` protocol.
    ///
    /// Optimally, this would override the delegate and redeclare the conforming protocol type as the
    /// source bar delegate, much like `UITableViewDelegate` extends `UIScrollViewDelegate` also.
    /// 
    /// The correct definiton of this property should be: `public override var delegate: SourceBarDelegate?`
    ///
    /// This is a language limitation. You should only use a SourceBarDelegate as the delegate for this
    /// class.
    public var sourceBarDelegate: SourceBarDelegate? {
        get { return delegate as? SourceBarDelegate }
        set { delegate = newValue }
    }
    
    
    
    fileprivate var _selectedIndex: Int?
    
    fileprivate var _highlightedIndex: Int?
    
    fileprivate var _dragCancelledHighlight: Bool = false
    
    fileprivate var _cells: [SourceBarCell] = []
    
    fileprivate var _needsCellReload: Bool = false
    
    
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
        accessibilityLabel = "Source Bar"
        if #available(iOS 10, *) {
            accessibilityTraits = UIAccessibilityTraitTabBar
        }
        
        setContentCompressionResistancePriority(UILayoutPriorityDefaultLow,  for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        setContentHuggingPriority(UILayoutPriorityFittingSizeLevel, for: .vertical)
        setContentHuggingPriority(UILayoutPriorityRequired - 1,     for: .horizontal)
        
        indicatorStyle = style == .dark ? .white : .black
        
        contentSize = CGSize(width: 64.0, height: 20.0)
        
        panGestureRecognizer.addTarget(self, action: #selector(scrollViewPanRecognizeStateDidChange(_:)))
    }
    
}

extension SourceBar {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        backgroundView?.frame = bounds
        
        if _needsCellReload == false { return }
        
        var reusableCells = _cells
        
        var frame = CGRect(x: 0.0, y: 10.0, width: 64.0, height: 77.0)
        
        _cells = items.enumerated().map {
            let cell: SourceBarCell
            if reusableCells.isEmpty == false {
                cell = reusableCells.remove(at: 0)
                cell.frame = frame
            } else {
                cell = SourceBarCell(frame: frame)
                cell.addTarget(self, action: #selector(touchDown(in:)), for: .touchDown)
                cell.addTarget(self, action: #selector(touchUp(in:)),   for: .touchUpInside)
                cell.addTarget(self, action: #selector(touchCancelled(in:)), for: [.touchCancel, .touchUpOutside])
                self.addSubview(cell)
            }
            
            cell.update(for: $0.element, withStyle: self.style)
            
            frame.origin.y += 77.0
            
            return cell
        }
        
        reusableCells.forEach { $0.removeFromSuperview() }
        
        updateCellSelection()
        
        accessibilityElements = _cells
    }
    
    public override func touchesShouldCancel(in view: UIView) -> Bool {
        if let cell = view as? SourceBarCell {
            // we override this to mimic the cell selection rules on table view - that is,
            // dragging on highlight clears highlight but doesn't resume selection until touch up
            // we don't do this on the selected cell tho
            _dragCancelledHighlight = _cells.index(of: cell) != _selectedIndex
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = contentSize
        if items.isEmpty {
            size.width = 0.0
        }
        return size
    }
    
}


fileprivate extension SourceBar {
    
    fileprivate func updateCellSelection() {
        _cells.enumerated().forEach {
            $0.element.isHighlighted = _highlightedIndex == $0.offset
            $0.element.isSelected    = _selectedIndex == $0.offset && _dragCancelledHighlight == false && (_highlightedIndex == nil || _highlightedIndex == $0.offset)
        }
    }
    
    @objc fileprivate func touchDown(in cell: SourceBarCell) {
        _highlightedIndex = _cells.index(of: cell)
        updateCellSelection()
    }
    
    @objc fileprivate func touchUp(in cell: SourceBarCell) {
        _highlightedIndex = nil
        if let selectedIndex = _cells.index(of: cell) {
            _selectedIndex = selectedIndex
            (delegate as? SourceBarDelegate)?.sourceBar(self, didSelectItemAt: selectedIndex)
        }
        updateCellSelection()
    }
    
    @objc fileprivate func touchCancelled(in cell: SourceBarCell) {
        _highlightedIndex = nil
        updateCellSelection()
    }
    
    @objc fileprivate func scrollViewPanRecognizeStateDidChange(_ recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .ended || recognizer.state == .cancelled) && _dragCancelledHighlight {
            // Handle where the pan ended, and we've got a "drag cancelled highlight" pause on highlights. Reset it to off and update selection.
            _dragCancelledHighlight = false
            updateCellSelection()
        }
    }
    
}


/// The delegate of a `SourceBar` object should adopt the SourceViewDelegate protocol.
/// The protocol provides callbacks for when the selected item changed.
@objc public protocol SourceBarDelegate: UIScrollViewDelegate {
    
    func sourceBar(_ bar: SourceBar, didSelectItemAt index: Int)
    
}
