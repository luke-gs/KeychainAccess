//
//  CollectionViewFormCell.swift
//  MPOLKit
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
open class CollectionViewFormCell: UICollectionViewCell, DefaultReusable, CollectionViewFormCellActionDelegate, UIGestureRecognizerDelegate {
    
    internal static let standardSeparatorColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
    
    
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
        
        case fade
        
        case underline
    }
    
    
    
    open var separatorStyle: SeparatorStyle = .indented {
        didSet {
            if separatorStyle != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    open var customSeparatorInsets: UIEdgeInsets? {
        didSet {
            if customSeparatorInsets == oldValue { return }
            
            setNeedsLayout()
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
            if isHighlighted == oldValue || highlightStyle == .none { return }
            updateSelectionHighlightAppearance()
        }
    }
    
    open var highlightStyle: HighlightStyle = .none {
        didSet {
            if isHighlighted == false || highlightStyle == oldValue { return }
            updateSelectionHighlightAppearance()
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected == oldValue || selectionStyle == .none { return }
            updateSelectionHighlightAppearance()
        }
    }
    
    open var selectionStyle: SelectionStyle = .none {
        didSet {
            if selectionStyle == oldValue || isSelected == false { return }
            updateSelectionHighlightAppearance()
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
    open var editActions: [CollectionViewFormEditAction] {
        get {
            return actionView.actions
        }
        set {
            actionView.actions = newValue
            cachedEditAccessiblityActions = nil
        }
    }
    
    
    /// The editing display state of the cell.
    ///
    /// This property manages the display of edit actions. Setting this value calls `setShowingEditActions: animated:`
    /// without an animation.
    open private(set) dynamic var isShowingEditActions: Bool {
        get {
            return actionView.isShowingActions
        }
        set { setShowingEditActions(isShowingEditActions, animated: false) }
    }
    
    
    /// Updates the editing display state of the cell.
    ///
    /// - Parameters:
    ///   - showingActions: A boolean value indicating whether the cell should show edit actions.
    ///   - animated:       A boolean flag indicating whether the update should be animated.
    open func setShowingEditActions(_ showingActions: Bool, animated: Bool) {
        actionView.setShowingActions(showingActions, animated: animated)
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
    
    private let separatorView = UIView(frame: .zero)
    
    internal let actionView = CollectionViewFormCellActionView(frame: .zero)
    
    /// The content mode guide. This guide is private and will update to enforce the current content
    /// mode on the `contentModeLayoutGuide`.
    private var contentModeLayoutVerticalConstraint: NSLayoutConstraint!
    
    private var contentModeLayoutTrailingConstraint: NSLayoutConstraint!
    
    private var touchTrigger: TouchRecognizer?
    
    private var isFirstInRow: Bool = false
    private var isAtTrailingEdge: Bool = false {
        didSet {
            actionView.wantsGradientMask = isAtTrailingEdge == false
        }
    }
    
    
    private var isRightToLeft: Bool = false {
        didSet { if isRightToLeft != oldValue { setNeedsLayout() } }
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
        separatorView.tintAdjustmentMode = .normal
        separatorView.isUserInteractionEnabled = false
        addSubview(separatorView)
        
        actionView.frame = bounds
        actionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        actionView.layoutMargins = layoutMargins
        actionView.actionDelegate = self
        addSubview(actionView)
        addGestureRecognizer(actionView.panGestureRecognizer)
        
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
        
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        }
        
        if #available(iOS 10, *) { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChangeNotification(_:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        removeTouchTrigger()
    }
    
    
    // MARK: - Content size updates
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, obsoleted: 10.0)
    @objc private func contentSizeCategoryDidChangeNotification(_ notification: Notification) {
        guard let newCategoryString = notification.userInfo?[UIContentSizeCategoryNewValueKey] as? String else { return }
        
        self.contentSizeCategoryDidChange(UIContentSizeCategory(rawValue: newCategoryString))
    }
    
    /// Informs the cell that the content size category did change. Subclasses should
    /// override this method to adjust the fonts of content where appropriate.
    ///
    /// - Important: From iOS 10 onwards, you should avoid setting the fonts for text labels
    ///              directly, and instead use the `UIContentSizeAdjusting` protocol
    ///
    /// - Parameter newCategory: The new content size category.
    public func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
    }
    
    
    // MARK: - Gesture recognizer delegate methods
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == touchTrigger {
            if let hitTestedView = actionView.hitTest(gestureRecognizer.location(in: actionView), with: nil),
                hitTestedView != actionView {
                return false
            }
            return true
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = gestureRecognizer.view
        let myCollectionView = view as? UICollectionView ?? view?.superview(of: UICollectionView.self)
        let returnValue = otherGestureRecognizer.view == myCollectionView
        return returnValue
    }
    
    
    // MARK: - CollectionViewFormCellActionDelegate methods
    
    func actionViewShouldBeginDragging(_ actionView: CollectionViewFormCellActionView) -> Bool {
        return firstResponderSubview() == nil
    }
    
    func actionViewWillShowActions(_ actionView: CollectionViewFormCellActionView) {
        superview(of: UICollectionView.self)?.endEditing(false)
        applyTouchTrigger()
    }
    
    func actionViewDidHideActions(_ actionView: CollectionViewFormCellActionView) {
        removeTouchTrigger()
    }
    
    func actionView(_ actionView: CollectionViewFormCellActionView, didSelectActionAt index: Int) {
        performEditAction(at: index)
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
        setShowingEditActions(false, animated: false)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setShowingEditActions(false, animated: false)
        removeTouchTrigger()
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let newLayoutMargins: UIEdgeInsets
        if let formAttribute = layoutAttributes as? CollectionViewFormLayoutAttributes {
            isFirstInRow     = formAttribute.rowIndex == 0
            isAtTrailingEdge = formAttribute.isAtTrailingEdge
            newLayoutMargins = formAttribute.layoutMargins
        } else {
            isFirstInRow     = false
            isAtTrailingEdge = false
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
        if actionView.layoutMargins != newLayoutMargins {
            actionView.layoutMargins = newLayoutMargins
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        
        let separatorInset: UIEdgeInsets
        if let customSeparatorInsets = self.customSeparatorInsets {
            separatorInset = customSeparatorInsets
        } else if separatorStyle != .fullWidth && (separatorStyle != .indentedAtRowLeading || isFirstInRow) {
            let layoutMargins = self.layoutMargins
            if isRightToLeft {
                separatorInset = UIEdgeInsets(top: 0.0, left: isAtTrailingEdge ? 0.0 : layoutMargins.left, bottom: 0.0, right: layoutMargins.right)
            } else {
                separatorInset = UIEdgeInsets(top: 0.0, left: layoutMargins.left, bottom: 0.0, right: isAtTrailingEdge ? 0.0 : layoutMargins.right)
            }
        } else {
            separatorInset = .zero
        }
        
        let separatorHeight = 1.0 / traitCollection.currentDisplayScale + (isSelected && selectionStyle == .underline ? 1.0 : 0.0)
        separatorView.frame = CGRect(x: separatorInset.left, y: bounds.height - separatorHeight, width: bounds.width - separatorInset.left - separatorInset.right, height: separatorHeight)
        separatorView.isHidden = separatorStyle == .none
        
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
        
        let subviews     = self.subviews
        let subviewCount = subviews.count
        
        if subviews.index(of: actionView) != subviewCount - 2 || subviews.index(of: separatorView) != subviewCount - 1 {
            bringSubview(toFront: actionView)
            bringSubview(toFront: separatorView)
        }
        
    }
    
    public final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    open override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let accessibilityActions = super.accessibilityCustomActions
            guard editActions.isEmpty == false else {
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
        
        let newCategory = traitCollection.preferredContentSizeCategory
        if newCategory != previousTraitCollection?.preferredContentSizeCategory ?? .unspecified {
            contentSizeCategoryDidChange(newCategory)
        }
        
        if (traitCollection.layoutDirection == .rightToLeft) != (previousTraitCollection?.layoutDirection == .rightToLeft) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
        
        if traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            setNeedsLayout()
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        if isSelected && selectionStyle == .underline {
            separatorView.backgroundColor = separatorView.tintColor
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateSelectionHighlightAppearance() {
        let isSelected     = self.isSelected
        let selectionStyle = self.selectionStyle
        
        let correctAlpha: CGFloat = (isSelected && selectionStyle == .fade) || (isHighlighted && highlightStyle == .fade) ? 0.5 : 1.0
        
        // Don't set unless necessary to avoid interfering with inflight animations.
        if contentView.alpha !=~ correctAlpha {
            contentView.alpha = correctAlpha
        }
        
        let wantsUnderline = isSelected && selectionStyle == .underline
        
        separatorView.backgroundColor = wantsUnderline ? separatorView.tintColor : separatorColor
        if (separatorView.frame.height > 1.0) != wantsUnderline {
            setNeedsLayout()
        }
    }
    
    @objc private func touchTriggerDidActivate(_ trigger: TouchRecognizer) {
        // Don't fire the trigger if it's within a view in the action view.
        if let hitTestedView = actionView.hitTest(trigger.location(in: actionView), with: nil),
            hitTestedView != actionView {
            return
        }
        
        setShowingEditActions(false, animated: true)
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
    
    // This method is declared fileprivate to allow associated classes to call back into the method.
    @discardableResult fileprivate func performEditAction(at index: Int) -> Bool {
        if editActions.count > index,
            let indexPath = superview(of: UICollectionView.self)?.indexPath(for: self) {
            editActions[index].handler?(self, indexPath)
            return true
        }
        return false
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

