//
//  CollectionViewFormCell.swift
//  MPOLKit/FormKit
//
//  Created by Rod Brown on 4/05/2016.
//  Copyright © 2016 Gridstone. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass


/// A basic cell that implements common form elements, including swipe-to-edit actions.
///
/// `CollectionViewFormCell` implements handling for `CollectionViewFormItemAttributes`. When used with a layout that
/// vends form item attributes, e.g. `CollectionViewFormLayout`, the cell adjusts its layout margins
/// to adhere to the form layout margins.
///
/// `CollectionViewFormCell` also blocks auto-layout based self sizing for performance reasons. Subclasses that wish to support
/// auto-layout based cell sizing should override `preferredLayoutAttributesFitting(_:)` and perform the caculations with
/// `systemLayoutSizeFitting(_:)`. Users should note that `CollectionViewFormLayout` does not support self-sizing cells.
open class CollectionViewFormCell: UICollectionViewCell, DefaultReusable, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private static let standardSeparatorColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
    
    
    @objc(CollectionViewFormSeparatorStyle) public enum SeparatorStyle: Int {
        case none
        
        case indented
        
        case indentedAtRowLeading
        
        case fullWidth
    }
    
    
    @objc(CollectionViewFormHighlightStyle) public enum HighlightStyle: Int {
        case none
        
        case fade
    }
    
    
    @objc(CollectionViewFormSelectionStyle) public enum SelectionStyle: Int {
        case none
        
        case underline
    }
    
    
    
    open var separatorStyle: SeparatorStyle = .indented {
        didSet {
            if separatorStyle != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    @NSCopying open var separatorColor: UIColor? = CollectionViewFormCell.standardSeparatorColor {
        didSet {
            if selectionStyle != .underline || isSelected == false {
                separatorView.backgroundColor = separatorColor
            }
        }
    }
    
    
    open override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted && highlightStyle == .fade ? 0.5 : 1.0
        }
    }
    
    open var highlightStyle: HighlightStyle = .none {
        didSet {
            if isHighlighted == false || highlightStyle == oldValue { return }
            
            contentView.alpha = highlightStyle == .fade ? 0.5 : 0.0
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected == oldValue { return }
            
            if selectionStyle == .underline {
                separatorView.backgroundColor = isSelected ? tintColor : separatorColor
                setNeedsLayout()
            }
            
        }
    }
    
    open var selectionStyle: SelectionStyle = .none {
        didSet {
            if selectionStyle == oldValue { return }
            
            if selectionStyle == .underline && isSelected {
                separatorView.backgroundColor = tintColor
                setNeedsLayout()
            } else {
                separatorView.backgroundColor = separatorColor
            }
        }
    }
    
    
    
    /// The accessory view for the cell.
    ///
    /// This will be placed at the trailing edge of the cell.
    open var accessoryView: UIView? {
        didSet {
            if oldValue == accessoryView { return }
            
            oldValue?.removeFromSuperview()
            
            if let accessoryView = self.accessoryView {
                contentView.addSubview(accessoryView)
                
                let accessoryWidth = accessoryView.frame.width
                if accessoryWidth > 0 {
                    contentModeLayoutTrailingConstraint.constant = (accessoryWidth + 10.0) * -1.0
                } else {
                    contentModeLayoutTrailingConstraint?.constant = 0.0
                }
            } else {
                contentModeLayoutTrailingConstraint?.constant = 0.0
            }
        }
    }
    
    
    // MARK: - Public properties
    
    /// The edit actions for the cell.
    /// 
    /// Setting this property will close edit actions if there are no more edit actions.
    open var editActions: [CollectionViewFormEditAction]? {
        didSet {
            if editActions?.isEmpty ?? true && oldValue?.isEmpty ?? true { return }
            
            let editActionCount = editActions?.count ?? 0
            
            if scrollView.isDragging == false {
                scrollView.isScrollEnabled = editActionCount != 0
                if editActionCount > 0 {
                    actionView?.updateForButtonsItems(editActions?.map {($0.title, $0.color)})
                }
            } else {
                if editActionCount == 0 {
                    scrollView.isScrollEnabled = false
                } else {
                    scrollView.isScrollEnabled = true
                    actionView?.updateForButtonsItems(editActions?.map {($0.title, $0.color)})
                }
            }
            
            cachedEditAccessiblityActions = nil
            scrollViewInset = CollectionViewFormCellActionView.singleButtonWidth * CGFloat(editActionCount)
        }
    }

    
    /// The editing display state of the cell.
    ///
    /// This property manages the display of edit actions. Setting this value calls `setShowingEditActions: animated:`
    /// without an animation.
    open private(set) dynamic var isShowingEditActions: Bool {
        get { return _isShowingEditActions }
        set { setShowingEditActions(isShowingEditActions, animated: false) }
    }
    
    
    /// Updates the editing display state of the cell.
    ///
    /// - Parameters:
    ///   - showingActions: A boolean value indicating whether the cell should show edit actions.
    ///   - animated:       A boolean flag indicating whether the update should be animated.
    open func setShowingEditActions(_ showingActions: Bool, animated: Bool) {
        if showingActions == false {
            removeTouchTrigger()
            if _isShowingEditActions {
                willChangeValue(forKey: #keyPath(isShowingEditActions))
                _isShowingEditActions = false
                didChangeValue(forKey: #keyPath(isShowingEditActions))
            }
            scrollView.setContentOffset(.zero, animated: animated)
            if !animated {
                removeActionView()
            } else {
                _scrolling = scrollView.contentOffset != .zero
            }
        } else {
            applyTouchTrigger()
            
            let offsetValue = CGFloat(actionView?.buttons?.count ?? 0) * CollectionViewFormCellActionView.singleButtonWidth
            let offset = CGPoint(x: isRightToLeft ? -offsetValue : offsetValue, y: 0.0)
            scrollView.setContentOffset(offset, animated: animated)
            
            if animated {
                _scrolling = scrollView.contentOffset != .zero
            }
        }
    }
    
    
    /// CollectionViewFormCell overrides this UIView flag to adjust the constraints on the
    /// `CollectionViewFormCell.contentModeLayoutGuide` to apply a top, bottom or center
    /// position to the guide.
    ///
    /// The default is `.center`.
    open override var contentMode: UIViewContentMode {
        didSet {
            if contentMode == oldValue { return }
            
            let attribute: NSLayoutAttribute
            switch contentMode {
            case .top, .topLeft, .topRight:
                attribute = .top
            case .bottom, .bottomLeft, .bottomRight:
                attribute = .bottom
            default:
                attribute = .centerY
            }
            contentModeLayoutVerticalConstraint?.isActive = false
            contentModeLayoutVerticalConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: attribute, relatedBy: .equal, toItem: contentView.layoutMarginsGuide, attribute: attribute, priority: UILayoutPriorityDefaultLow - 1)
            contentModeLayoutVerticalConstraint.isActive = true
            
            if accessoryView != nil {
                setNeedsLayout()
            }
        }
    }
    
    
    /// This layout guide is applied to the cell's contentView, and positions content in the
    /// correct vertical position for the current `contentMode`. This layout guide is constrainted
    /// to the layout margins for the content view.
    ///
    /// Subclasses should position their content with this layout guide, rather than the content
    /// view's layout margins.
    open let contentModeLayoutGuide: UILayoutGuide = UILayoutGuide()
    
    
    // MARK: - Private properties
    
    fileprivate let scrollView = CollectionViewFormCellScrollView(frame: .zero)
    
    private let separatorView = UIView(frame: .zero)
    
    /// The content mode guide. This guide is private and will update to enforce the current content
    /// mode on the `contentModeLayoutGuide`.
    private var contentModeLayoutVerticalConstraint: NSLayoutConstraint!
    
    private var contentModeLayoutTrailingConstraint: NSLayoutConstraint!
    
    private var actionView: CollectionViewFormCellActionView?
    private var _isShowingEditActions: Bool = false
    private var _deceleratingToOpen: Bool = false
    private var _scrolling: Bool    = false
    private var touchTrigger: TouchRecognizer?
    
    private var isFirstInRow: Bool = false
    
    
    private var isRightToLeft: Bool = false {
        didSet {
            if isRightToLeft == oldValue { return }
            
            scrollView.contentInset = scrollView.contentInset.horizontallyFlipped()
            
            var contentOffset = scrollView.contentOffset
            contentOffset.x = -contentOffset.x
            scrollView.contentOffset = contentOffset
            
            update(for: contentOffset)
            
            setNeedsLayout()
        }
    }
    
    private var scrollViewInset: CGFloat = 0.0 {
        didSet {
            let dragging = scrollView.isDragging
            if dragging || scrollView.contentOffset.x.isZero == false {
                if isRightToLeft {
                    scrollView.contentInset.left = scrollViewInset
                } else {
                    scrollView.contentInset.right = scrollViewInset
                }
            }
            if dragging == false {
                setShowingEditActions(isShowingEditActions, animated: window != nil)
            }
        }
    }
    
    private var cachedEditAccessiblityActions: [CollectionViewFormAccessibilityEditAction]?
    
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isAccessibilityElement = true
        
        separatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        separatorView.backgroundColor = separatorColor
        separatorView.isUserInteractionEnabled = false
        addSubview(separatorView)
        
        super.contentMode = .center
        
        let contentView            = super.contentView
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        contentView.addLayoutGuide(contentModeLayoutGuide)
        
        contentModeLayoutVerticalConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerYWithinMargins, priority: UILayoutPriorityDefaultLow - 1)
        contentModeLayoutTrailingConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .top,      relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .topMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .bottom,   relatedBy: .lessThanOrEqual,    toItem: contentView, attribute: .bottomMargin, priority: 500),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .leading,  relatedBy: .equal, toItem: contentView, attribute: .leadingMargin),
            contentModeLayoutTrailingConstraint,
            contentModeLayoutVerticalConstraint
        ])
        
        applyStandardFonts()
        
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        }
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        removeTouchTrigger()
    }
    
    
    // MARK: - Font updates
    
    /// Applies the standard fonts for the cell.
    ///
    /// This method is internal-only, and is expected to be called on reuse, and during
    /// init methods.
    ///
    /// - Important: Subclasses must ensure that it is safe to call this method by
    ///              `super.init()`, as it is called during the superclass's
    ///              initializer.
    internal func applyStandardFonts() {
    }
    
    
    // MARK: - Scroll handling
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        
        if isRightToLeft {
            if contentOffset.x > 0 {
                contentOffset.x = 0.0
                scrollView.contentOffset = contentOffset
            } else if contentOffset.x < -scrollView.bounds.width {
                contentOffset.x = -scrollView.bounds.width
                scrollView.contentOffset = contentOffset
            }
        } else {
            if contentOffset.x < 0 {
                contentOffset.x = 0.0
                scrollView.contentOffset = contentOffset
            } else if contentOffset.x > scrollView.bounds.width {
                contentOffset.x = scrollView.bounds.size.width
                scrollView.contentOffset = contentOffset
            }
        }
        
        update(for: contentOffset)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let xVelocity = velocity.x
        
        var movingIntoEditing = false
        
        if isRightToLeft {
            if xVelocity > 0.25 {
                targetContentOffset.pointee.x = 0.0
            } else if xVelocity < -1.0 {
                targetContentOffset.pointee.x = -scrollView.contentInset.left
                movingIntoEditing = true
            } else {
                let contentInset = scrollView.contentInset.left
                if targetContentOffset.pointee.x < (contentInset / -2.0) {
                    movingIntoEditing = true
                    targetContentOffset.pointee.x = -contentInset
                } else {
                    targetContentOffset.pointee.x = 0.0
                }
            }
        } else {
            if xVelocity < -0.25 {
                targetContentOffset.pointee.x = 0.0
            } else if xVelocity > 1.0 {
                targetContentOffset.pointee.x = scrollView.contentInset.right
                movingIntoEditing = true
            } else {
                let contentInset = scrollView.contentInset.right
                if targetContentOffset.pointee.x > (contentInset / 2.0) {
                    movingIntoEditing = true
                    targetContentOffset.pointee.x = contentInset
                } else {
                    targetContentOffset.pointee.x = 0.0
                }
            }
        }
        
        if movingIntoEditing {
            _deceleratingToOpen = true
            applyTouchTrigger()
        } else {
            _deceleratingToOpen = false
            removeTouchTrigger()
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            _deceleratingToOpen = false
            if scrollView.contentOffset.x.isZero {
                removeActionView()
            }
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let collectionView = superview(of: UICollectionView.self)
        collectionView?.endEditing(true)
        
        if isRightToLeft {
            scrollView.contentInset.left = scrollViewInset
        } else {
            scrollView.contentInset.right = scrollViewInset
        }
        _deceleratingToOpen = false
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let showing = scrollView.contentOffset.x.isZero == false
        if _isShowingEditActions != showing {
            willChangeValue(forKey: #keyPath(isShowingEditActions))
            _isShowingEditActions = showing
            didChangeValue(forKey: #keyPath(isShowingEditActions))
        }
        _deceleratingToOpen = false
        if showing == false {
            removeActionView()
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let showing = scrollView.contentOffset.x.isZero == false
        if _isShowingEditActions != showing {
            willChangeValue(forKey: #keyPath(isShowingEditActions))
            _isShowingEditActions = showing
            didChangeValue(forKey: #keyPath(isShowingEditActions))
        }
        _deceleratingToOpen = false
        _scrolling = false
        if showing == false {
            removeActionView()
        }
    }
    
    fileprivate func update(for scrollContentOffset: CGPoint) {
        let size = scrollView.bounds.size
        
        if actionView == nil && scrollContentOffset.x.isZero == false {
            superview(of: UICollectionView.self)?.endEditing(true)
            actionView = CollectionViewFormCellActionView(frame: .zero)
            actionView!.cell = self
            actionView!.updateForButtonsItems((editActions?.map { let color = $0.color ?? .gray;
                return ($0.title, color)}))
            scrollView.addSubview(actionView!)
        }
        
        var frame: CGRect
        if isRightToLeft {
            frame = CGRect(x: scrollContentOffset.x, y: 0.0, width: -scrollContentOffset.x, height: size.height)
        } else {
            frame = CGRect(x: size.width, y: 0.0, width: scrollContentOffset.x, height: size.height)
        }
        actionView?.frame = frame
    }
    
    
    // MARK: - Gesture recognizer delegate methods
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let actionView = self.actionView {
            if actionView.bounds.contains(gestureRecognizer.location(in: actionView)) {
                return false
            }
        }
        return true
    }
    
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = gestureRecognizer.view
        let myCollectionView = view as? UICollectionView ?? view?.superview(of: UICollectionView.self)
        let returnValue = otherGestureRecognizer.view == myCollectionView
        return returnValue
    }
    
    
    // MARK: - Overrides
    
    open class override func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == #keyPath(CollectionViewFormCell.isShowingEditActions) {
            return false
        } else {
            return super.automaticallyNotifiesObservers(forKey: key)
        }
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute == oldValue { return }
            
            if #available(iOS 10, *) {
                isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
            } else {
                isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
            }
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        applyStandardFonts()
        setNeedsLayout()
        setShowingEditActions(false, animated: false)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        removeTouchTrigger()
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let newLayoutMargins: UIEdgeInsets
        if let formAttribute = layoutAttributes as? CollectionViewFormItemAttributes {
            isFirstInRow     = formAttribute.rowIndex == 0
            newLayoutMargins = formAttribute.layoutMargins
        } else {
            isFirstInRow     = false
            newLayoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
        
        if layoutMargins != newLayoutMargins {
            layoutMargins = newLayoutMargins
            setNeedsLayout()
        }
        if contentView.layoutMargins != newLayoutMargins {
            contentView.layoutMargins = newLayoutMargins
            setNeedsLayout()
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitTestedView = super.hitTest(point, with: event) else { return nil }
        
        if _scrolling { return self }
        
        
        // If we're dragging, don't receive additional touches.
        if scrollView.isDragging {
            return scrollView
        }
        
        // If the scroll view is decelerating, only accept touches on the action view, and only when decelerating to open.
        // If not decelerating to open or not touching the action view, pass the touch to the content view.
        // This will ensure we won't get selection activity, but we can still catch scroll behaviour.
        if scrollView.isDecelerating {
            if _deceleratingToOpen,
                let actionView = self.actionView, hitTestedView.isDescendant(of: actionView) {
                    return hitTestedView
            } else {
                return self
            }
        }
        
        // The hit test on the cell will find the content view, the scroll view or a subview. The content view
        // and the scroll view will block selection. If we're not currently showing edit actions, return ourself instead,
        // to allow selection to occur.
        if isShowingEditActions == false && (hitTestedView == contentView || hitTestedView == scrollView) {
            return self
        }
        
        return hitTestedView
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        let separatorHeight = 1.0 / traitCollection.currentDisplayScale + (isSelected && selectionStyle == .underline ? 1.0 : 0.0)
        var separatorFrame = CGRect(x: 0.0, y: bounds.height - separatorHeight, width: bounds.width, height: separatorHeight)
        
        if separatorStyle != .fullWidth && (separatorStyle != .indentedAtRowLeading || isFirstInRow) {
            if isRightToLeft {
                separatorFrame.size.width -= layoutMargins.right
            } else {
                let leftMargin = layoutMargins.left
                separatorFrame.size.width -= leftMargin
                separatorFrame.origin.x   += leftMargin
            }
        }
        separatorView.frame = separatorFrame
        separatorView.isHidden = separatorStyle == .none
        bringSubview(toFront: separatorView)
        
        if let accessoryView = self.accessoryView {
            let contentLayoutGuide = contentModeLayoutGuide.layoutFrame
            
            var accessoryFrame = accessoryView.frame
            accessoryFrame.origin.y = round(contentLayoutGuide.midY - (accessoryFrame.size.height * 0.5))
            if isRightToLeft {
                accessoryFrame.origin.x = contentLayoutGuide.minX - 10.0 - accessoryFrame.width
            } else {
                accessoryFrame.origin.x = contentLayoutGuide.maxX + 10.0
            }
            accessoryView.frame = accessoryFrame
        }
        
    }
    
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    open override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let accessibilityActions = super.accessibilityCustomActions
            guard let editActions = self.editActions, editActions.isEmpty == false else {
                return accessibilityActions
            }
            
            var accessibilityCustomActions = accessibilityActions ?? []
            
            if cachedEditAccessiblityActions == nil {
                cachedEditAccessiblityActions = editActions.enumerated().map { CollectionViewFormAccessibilityEditAction(cell: self, title: $0.element.title, actionIndex: $0.offset) }
            }
            
            if let actions: [UIAccessibilityCustomAction] = cachedEditAccessiblityActions {
                accessibilityCustomActions += actions
            }
            
            return accessibilityCustomActions
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard #available(iOS 10, *) else { return }
        
        if (traitCollection.layoutDirection == .rightToLeft) != (previousTraitCollection?.layoutDirection == .rightToLeft) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
        
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            applyStandardFonts()
            setNeedsLayout()
        }
        
        if traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            setNeedsLayout()
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        if isSelected && selectionStyle == .underline {
            separatorView.backgroundColor = tintColor
        }
    }
    
    
    // MARK: - Private methods
    
    @objc private func touchTriggerDidActivate(_ trigger: TouchRecognizer) {
        // Don't fire the trigger if it's within the action view.
        if let actionView = self.actionView , actionView.bounds.contains(trigger.location(in: actionView)) {
            return
        }
        
        self.setShowingEditActions(false, animated: true)
    }
    
    private func applyTouchTrigger() {
        if touchTrigger != nil { return }
        if let collectionView = superview(of: UICollectionView.self) {
            let touchTrigger = TouchRecognizer(target: self, action: #selector(touchTriggerDidActivate(_:)))
            touchTrigger.delegate = self
            collectionView.addGestureRecognizer(touchTrigger)
            self.touchTrigger = touchTrigger
        }
    }
    
    private func removeTouchTrigger() {
        if let touchTrigger = self.touchTrigger {
            touchTrigger.view?.removeGestureRecognizer(touchTrigger)
            self.touchTrigger = nil
        }
    }
    
    private func removeActionView() {
        scrollView.contentInset.left  = 0.0
        scrollView.contentInset.right = 0.0
        if let actionView = self.actionView {
            actionView.removeFromSuperview()
            self.actionView = nil
        }
    }
    
    // This method is declared fileprivate to allow associated classes to call back into the method.
    @discardableResult fileprivate func performEditAction(at index: Int) -> Bool {
        let editCount = editActions?.count ?? 0
        
        if editCount > index,
            let indexPath = superview(of: UICollectionView.self)?.indexPath(for: self) {
            editActions?[index].action?(self, indexPath)
            return true
        }
        return false
    }
    
    @objc private func contentSizeCategoryDidChange(_ notification: Notification) {
        applyStandardFonts()
        setNeedsLayout()
    }
    
}



/// A private subclass of UIScrollView to handle the gesture recognizer delegate
/// actions which cannot be accessed any other way.
private class CollectionViewFormCellScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    weak var cell: CollectionViewFormCell?
    
    override var frame: CGRect {
        didSet {
            if frame.size.equalTo(contentSize) == false { contentSize = frame.size }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        panGestureRecognizer.delegate = self
        decelerationRate = (UIScrollViewDecelerationRateFast + UIScrollViewDecelerationRateNormal) / 2.0
        delaysContentTouches = false
        alwaysBounceVertical = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isDirectionalLockEnabled = true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cells = cell?.superview(of: UICollectionView.self)?.visibleCells {
            if cells.contains(where: {
                if let state = ($0 as? CollectionViewFormCell)?.scrollView.panGestureRecognizer.state {
                    return state != .possible && state != .failed
                }
                return false
            }) {
                return false
            }
        }
        if contentOffset.x.isZero && firstResponderSubview() != nil {
            return false
        }
        return true
    }
    
}


/// A private view which manages the editing buttons for the cell.
fileprivate class CollectionViewFormCellActionView: UIView {
    
    static let singleButtonWidth: CGFloat = 80.0
    
    weak var cell: CollectionViewFormCell?
    
    var buttons: [UIButton]?
    
    override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        UIView.performWithoutAnimation {
            let bounds = self.bounds
            let buttonWidth = CollectionViewFormCellActionView.singleButtonWidth
            
            let isRightToLeft: Bool
            if #available(iOS 10, *) {
                isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
            } else {
                isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
            }
            
            if isRightToLeft {
                var startX: CGFloat = 0.0
                
                self.buttons?.forEach { (button: UIButton) in
                    button.frame = CGRect(x: startX, y: 0.0, width: buttonWidth, height: bounds.height)
                    button.layoutIfNeeded()
                    startX += buttonWidth
                }
            } else {
                var startX: CGFloat = bounds.width - buttonWidth
                
                self.buttons?.forEach { (button: UIButton) in
                    button.frame = CGRect(x: startX, y: 0.0, width: buttonWidth, height: bounds.height)
                    button.layoutIfNeeded()
                    startX -= buttonWidth
                }
            }
            
        }
    }
    
    func updateForButtonsItems(_ items:[(title: String, color: UIColor?)]?) {
        buttons?.forEach { $0.removeFromSuperview() }
        var reusableButtons = buttons
        buttons = items?.enumerated().map {
            let button: UIButton
            if let dequeuedButton = reusableButtons?.popLast() {
                button = dequeuedButton
            } else {
                button = UIButton(type: .custom)
                button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchCancel)
                button.setTitleColor(.white, for: .normal)
                button.setTitleColor(.gray, for: .highlighted)
            }
            button.backgroundColor = $0.element.color ?? .gray
            button.setTitle($0.element.title, for: .normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.tag = $0.offset
            self.addSubview(button)
            return button
        }
        
        setNeedsLayout()
    }
    
    @objc func buttonDidTap(_ button: UIButton) {
        cell?.performEditAction(at: button.tag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *),
            (traitCollection.layoutDirection == .rightToLeft) != (previousTraitCollection?.layoutDirection == .rightToLeft) {
            setNeedsLayout()
        }
        
        if traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            setNeedsLayout()
        }
    }
    
}


/// A private class used to recognize a touch beginning on a view, or it's subviews.
/// This gesture should not interfere with other gesture recognizers eg scrolling.
fileprivate class TouchRecognizer: UIGestureRecognizer {
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.recognized
    }
}


fileprivate class CollectionViewFormAccessibilityEditAction: UIAccessibilityCustomAction {
    
    weak var cell: CollectionViewFormCell?
    
    let actionIndex: Int
    
    init(cell: CollectionViewFormCell, title: String, actionIndex: Int) {
        self.cell = cell
        self.actionIndex = actionIndex
        super.init(name: title, target: nil, selector: #selector(performAction))
        target = self
    }
    
    @objc func performAction() -> Bool {
        return cell?.performEditAction(at: actionIndex) ?? false
    }
    
}

