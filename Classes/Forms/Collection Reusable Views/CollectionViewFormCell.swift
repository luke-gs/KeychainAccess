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
    
    // MARK: - Class methods
    
    public static let accessoryContentInset: CGFloat = 12.0
    
    public class func heightForValidationAccessory(withText text: String, contentWidth: CGFloat, compatibleWith traitCollection: UITraitCollection) -> CGFloat {
        if text.isEmpty { return 0.0 }
        
        let font = UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        let textBounds = (text as NSString).boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        return textBounds.height.ceiled(toScale: traitCollection.currentDisplayScale) + 12.0
    }
    
    // MARK: - Associated types
    
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
    
    
    // MARK: - Public properties
    
    
    open var separatorStyle: SeparatorStyle = .indented {
        didSet {
            if separatorStyle == oldValue { return }
            
            separatorView.isHidden = separatorStyle == .none
            setNeedsLayout()
        }
    }
    
    
    /// The separator insets for the cell.
    ///
    /// The left and right for these values are treated as leading and trailing
    /// respectively. In future versions, this property will be transitioned to
    /// `NSDirectionalEdgeInsets`.
    open var customSeparatorInsets: UIEdgeInsets? {
        didSet {
            if customSeparatorInsets == oldValue { return }
            
            setNeedsLayout()
        }
    }
    
    
    @NSCopying open var separatorColor: UIColor? = iOSStandardSeparatorColor {
        didSet {
            if requiresValidation && validationColor != nil {
                return
            }
            if selectionStyle != .underline || isSelected == false {
                updateSeparatorColor()
            }
        }
    }
    
    @NSCopying open var separatorTintColor: UIColor? = nil {
        didSet {
            separatorView.tintColor = separatorTintColor
            if requiresValidation && validationColor != nil && selectionStyle == .underline && isSelected {
                updateSeparatorColor()
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
    /// This will be placed at the trailing edge of the cell, and is resized
    /// via `UIView.sizeThatFits(_:)`. Labels, for example, can be set to
    /// adjust their fonts for the content size category, and the cell will
    /// automatically resize the view as the size category changes.
    open var accessoryView: UIView? {
        didSet {
            if oldValue != accessoryView {
                oldValue?.removeFromSuperview()
                
                if let accessoryView = self.accessoryView {
                    contentView.addSubview(accessoryView)
                } else {
                    contentModeLayoutTrailingConstraint?.constant = 0.0
                }
            }
            
            setNeedsLayout()
        }
    }
    
    /// The edit actions for the cell.
    ///
    /// Setting this property will close edit actions if there are no more edit actions.
    open var editActions: [CollectionViewFormEditAction] {
        get {
            return actionView?.actions ?? []
        }
        set {
            if newValue.isEmpty == false && actionView == nil {
                let view = CollectionViewFormCellActionView(frame: self.bounds)
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.layoutMargins = self.layoutMargins
                view.actionDelegate = self
                self.insertSubview(view, belowSubview: self.separatorView)
                addGestureRecognizer(view.panGestureRecognizer)
                actionView = view
            }
            
            actionView?.actions = newValue
            cachedEditAccessiblityActions = nil
        }
    }
    
    
    /// The editing display state of the cell.
    ///
    /// This property manages the display of edit actions. Setting this value calls `setShowingEditActions: animated:`
    /// without an animation.
    @objc open private(set) dynamic var isShowingEditActions: Bool {
        get {
            return actionView?.isShowingActions ?? false
        }
        set {
            setShowingEditActions(isShowingEditActions, animated: false)
        }
    }
    
    
    /// Updates the editing display state of the cell.
    ///
    /// - Parameters:
    ///   - showingActions: A boolean value indicating whether the cell should show edit actions.
    ///   - animated:       A boolean flag indicating whether the update should be animated.
    open func setShowingEditActions(_ showingActions: Bool, animated: Bool) {
        actionView?.setShowingActions(showingActions, animated: animated)
    }
    
    
    // MARK: - Validation
    
    
    /// The validation color for the cell.
    /// 
    /// This will be used for the separator color when the cell requires validation,
    /// as well as for the validation accessory label.
    @NSCopying open var validationColor: UIColor? = .red {
        didSet {
            if requiresValidation == false { return }
            
            updateSeparatorColor()
            validationAccessoryLabel?.textColor = validationColor ?? .gray
        }
    }
    
    
    /// Sets the cell into a validating or non-validating state.
    ///
    /// - Important: When setting the validation with animation and updating label state,
    ///              the cell invalidates the layout to ensure the room expands and allows
    ///              the delegate to specify the appropriate size as part of the animation.
    ///              When setting without an animation, it is the setter's responsibility
    ///              to invalidate the layout (thus this method can be used during reuse).
    ///
    /// - Parameters:
    ///   - requiresValidation: A boolean value indicating whether there the cell requires validation.
    ///   - validationText:     The text to show as a validation accessory. If `requiresValidation` is false
    ///                         this text is ignored.
    ///   - alignment:          The alignment of the text
    ///   - animated:           A boolean value indicating whether the update should be animated.
    open func setRequiresValidation(_ requiresValidation: Bool, validationText: String?, alignment: NSTextAlignment = .natural, animated: Bool) {
        if requiresValidation == self.requiresValidation && (requiresValidation == false || (validationText == validationAccessoryLabel?.text && alignment == validationAccessoryLabel?.textAlignment)) {
            return // Current state already.
        }
        
        let wantsValidationText = requiresValidation && (validationText?.isEmpty ?? true == false)
        
        func newValidationLabel() -> UILabel {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 0
            label.adjustsFontForContentSizeCategory = true
            label.textColor = validationColor ?? .gray
            label.textAlignment = alignment
            label.font = .preferredFont(forTextStyle: .footnote, compatibleWith: label.traitCollection)
            contentView.addSubview(label)
            
            return label
        }
        
        if animated {
            let oldLabel = self.validationAccessoryLabel
            if wantsValidationText {
                validationAccessoryLabel = newValidationLabel()
                setNeedsLayout()
            } else {
                validationAccessoryLabel = nil
            }
            oldValidationAccessoryLabel = oldLabel
            let newLabel = validationAccessoryLabel
            newLabel?.text = validationText
            newLabel?.alpha = 0.0
            layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                if newLabel != nil || oldLabel != nil {
                    // labels are changing.
                    newLabel?.alpha = 1.0
                    oldLabel?.alpha = 0.0
                    
                    let collectionView = self.superview(of: UICollectionView.self)
                    collectionView?.performBatchUpdates({
                        collectionView?.collectionViewLayout.invalidateLayout()
                    })
                }
                
                self.requiresValidation = requiresValidation
                self.layoutIfNeeded()
            }, completion: { [weak self] finished in
                if self?.oldValidationAccessoryLabel == oldLabel {
                    self?.oldValidationAccessoryLabel = nil
                }
                oldLabel?.removeFromSuperview()
            })
        } else {
            if wantsValidationText {
                if let currentLabel = validationAccessoryLabel {
                    currentLabel.text = validationText
                    currentLabel.textAlignment = alignment
                } else {
                    let newLabel = newValidationLabel()
                    newLabel.text = validationText
                    newLabel.textAlignment = alignment
                    validationAccessoryLabel = newLabel
                }
            } else {
                validationAccessoryLabel?.removeFromSuperview()
                validationAccessoryLabel = nil
            }
            self.requiresValidation = requiresValidation
        }
    }
    
    
    /// CollectionViewFormCell subclasses use this `UIView` property to adjust their contents.
    /// Subclasses can implement this behavior themselves, or can use autolayout and constrain
    /// against the `CollectionViewFormCell.contentModeLayoutGuide`.
    ///
    /// The default is `.center`.
    open override var contentMode: UIViewContentMode {
        didSet {
            if contentMode == oldValue { return }
            
            if let contentModeConstraint = contentModeLayoutVerticalConstraint {
                let attribute: NSLayoutAttribute
                switch contentMode {
                case .top, .topLeft, .topRight:
                    attribute = .top
                case .bottom, .bottomLeft, .bottomRight:
                    attribute = .bottom
                default:
                    attribute = .centerY
                }
                contentModeConstraint.isActive = false
                contentModeLayoutVerticalConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: attribute, relatedBy: .equal, toItem: contentView.layoutMarginsGuide, attribute: attribute, priority: UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.defaultLow.rawValue) - 1)))
                contentModeLayoutVerticalConstraint!.isActive = true
            }
            
            setNeedsLayout()
        }
    }
    
    
    /// This layout guide is applied to the cell's contentView, and positions content in the
    /// correct vertical position for the current `contentMode`. This layout guide is constrainted
    /// to the layout margins for the content view.
    ///
    /// Subclasses should either position their content manually, or constraint against this guide
    /// rather than the content view's layout margins to get the correct behaviour for the content
    /// mode.
    ///
    /// - Note: Subclasses that will be used frequently, with lots of cells being allocated in
    ///         quick succession, may find their performance constrained by Auto Layout on slower
    ///         devices e.g. iPad mini. You may need to  consider using manual layout instead.
    open var contentModeLayoutGuide: UILayoutGuide {
        if let existingGuide = _contentModeLayoutGuide { return existingGuide }
        
        let layoutGuide = UILayoutGuide()
        let contentView = self.contentView
        let contentLayoutGuide = contentView.layoutMarginsGuide
        
        contentView.addLayoutGuide(layoutGuide)
        _contentModeLayoutGuide = layoutGuide
        
        let attribute: NSLayoutAttribute
        switch contentMode {
        case .top, .topLeft, .topRight:
            attribute = .top
        case .bottom, .bottomLeft, .bottomRight:
            attribute = .bottom
        default:
            attribute = .centerY
        }
        contentModeLayoutVerticalConstraint = NSLayoutConstraint(item: layoutGuide, attribute: attribute, relatedBy: .equal, toItem: contentView.layoutMarginsGuide, attribute: attribute, priority: UILayoutPriority(rawValue: UILayoutPriority.RawValue(Int(UILayoutPriority.defaultLow.rawValue) - 1)))
        contentModeLayoutTrailingConstraint = layoutGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor)
        
        NSLayoutConstraint.activate([
            layoutGuide.topAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.topAnchor),
            layoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.bottomAnchor).withPriority(UILayoutPriority(rawValue: 500)),
            layoutGuide.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentModeLayoutTrailingConstraint!,
            contentModeLayoutVerticalConstraint!,
        ])
        
        return layoutGuide
    }
    
    
    // MARK: - Private properties
    
    internal var actionView: CollectionViewFormCellActionView?
    
    private let separatorView = UIView()
    
    private var requiresValidation: Bool = false {
        didSet {
            if requiresValidation == oldValue { return }
            
            updateSeparatorColor()
            
            if isSelected == false || selectionStyle != .underline {
                setNeedsLayout()
            }
        }
    }
    
    private var validationAccessoryLabel: UILabel?
    
    private var oldValidationAccessoryLabel: UILabel?
    
    
    private var _contentModeLayoutGuide: UILayoutGuide?
    
    private var contentModeLayoutVerticalConstraint: NSLayoutConstraint?
    
    private var contentModeLayoutTrailingConstraint: NSLayoutConstraint?
    
    
    private var touchTrigger: TouchRecognizer?
    
    private var isFirstInRow: Bool = false
    
    private var isAtTrailingEdge: Bool = false {
        didSet {
            if isAtTrailingEdge == oldValue { return }
            actionView?.wantsGradientMask = isAtTrailingEdge == false
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
    
    /// An internal common point for subclasses to override without having to override
    /// initializers within MPOLKit. When overriding, you must call `super.commonInit()`
    /// **first** as part of your implementation.
    internal func commonInit() {
        isAccessibilityElement = true
        super.contentMode = .center
        
        separatorView.backgroundColor = separatorColor
        separatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(separatorView)
    }
    
    deinit {
        removeTouchTrigger()
    }
    
    
    // MARK: - Content size updates
    
    /// Informs the cell that the content size category did change. Subclasses should
    /// override this method to adjust the fonts of content where appropriate.
    ///
    /// - Parameter newCategory: The new content size category.
    public func contentSizeCategoryDidChange(_ newCategory: UIContentSizeCategory) {
    }
    
    /// The current content rectangle considering space for the layout margins and accessory view.
    open func contentRect() -> CGRect {
        var contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
        
        if let accessorySize = accessoryView?.frame.size, accessorySize.isEmpty == false {
            let inset = accessorySize.width + CollectionViewFormCell.accessoryContentInset
            contentRect.size.width -= inset
            if effectiveUserInterfaceLayoutDirection == .rightToLeft {
                contentRect.origin.x += inset
            }
        }
        
        return contentRect
    }
    
    
    // MARK: - Gesture recognizer delegate methods
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == touchTrigger {
            if let hitTestedView = actionView?.hitTest(gestureRecognizer.location(in: actionView), with: nil),
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        setShowingEditActions(false, animated: false)
        setNeedsLayout()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setShowingEditActions(false, animated: false)
        removeTouchTrigger()
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let newLayoutMargins: UIEdgeInsets
        let newAtTrailingEdge: Bool
        if let formAttribute = layoutAttributes as? CollectionViewFormLayoutAttributes {
            isFirstInRow     = formAttribute.rowIndex == 0
            newAtTrailingEdge = formAttribute.isAtTrailingEdge
            newLayoutMargins = formAttribute.layoutMargins
        } else {
            isFirstInRow     = false
            newAtTrailingEdge = false
            newLayoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
        
        var needsLayout = false
        
        if isAtTrailingEdge != newAtTrailingEdge {
            self.isAtTrailingEdge = newAtTrailingEdge
            needsLayout = true
        }
        
        if layoutMargins != newLayoutMargins {
            layoutMargins = newLayoutMargins
            needsLayout = true
        }
        if contentView.layoutMargins != newLayoutMargins {
            contentView.layoutMargins = newLayoutMargins
            needsLayout = true
        }
        if let actionView = self.actionView, actionView.layoutMargins != newLayoutMargins {
            actionView.layoutMargins = newLayoutMargins
        }
        
        if needsLayout {
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        
        // Update accessory location
        
        if let accessoryView = self.accessoryView {
            
            let contentRect = contentView.bounds.insetBy(contentView.layoutMargins)
            
            var accessoryFrame = CGRect(origin: .zero, size: accessoryView.sizeThatFits(contentRect.size).constrained(to: contentRect.size))
            accessoryFrame.origin.y = (contentRect.midY - (accessoryFrame.height * 0.5)).rounded(toScale: traitCollection.currentDisplayScale)
            accessoryFrame.origin.x = isRTL ? contentRect.minX : contentRect.maxX - accessoryFrame.width
            accessoryView.frame = accessoryFrame
            
            let accessoryWidth = accessoryView.frame.width
            if accessoryWidth > 0 {
                contentModeLayoutTrailingConstraint?.constant = (accessoryFrame.width + CollectionViewFormCell.accessoryContentInset) * -1.0
            } else {
                contentModeLayoutTrailingConstraint?.constant = 0.0
            }
        }
        
        // Update separator position
        
        let bounds = self.bounds
        let layoutMargins = self.layoutMargins
        
        let separatorInset: UIEdgeInsets
        if let customSeparatorInsets = self.customSeparatorInsets {
            if isRTL {
                separatorInset = customSeparatorInsets.horizontallyFlipped()
            } else {
                separatorInset = customSeparatorInsets
            }
        } else if separatorStyle != .fullWidth {
            let indentLeading  = separatorStyle != .indentedAtRowLeading || isFirstInRow
            let indentTrailing = separatorStyle != .indentedAtRowLeading && isAtTrailingEdge == false
            
            if isRTL {
                separatorInset = UIEdgeInsets(top: 0.0, left: indentTrailing ? layoutMargins.left : 0.0, bottom: 0.0, right: layoutMargins.right)
            } else {
                separatorInset = UIEdgeInsets(top: 0.0, left: indentLeading ? layoutMargins.left : 0.0, bottom: 0.0, right: indentTrailing ? layoutMargins.right : 0.0)
            }
        } else {
            separatorInset = .zero
        }
        
        let separatorHeight = 1.0 / traitCollection.currentDisplayScale + ((isSelected && selectionStyle == .underline) || requiresValidation ? 1.0 : 0.0)
        let separatorFrame = CGRect(x: separatorInset.left, y: bounds.height - separatorHeight, width: bounds.width - separatorInset.left - separatorInset.right, height: separatorHeight)
        if separatorView.frame != separatorFrame {
            separatorView.frame = separatorFrame
        }
        separatorView.isHidden = separatorStyle == .none
        
        
        // Validation layout
        
        func layoutValidationLabel(_ label: UILabel) {
            let leftInset  = max(layoutMargins.left,  separatorInset.left, 0.0)
            let rightInset = max(layoutMargins.right, separatorInset.right, 0.0)
            
            let horizontalSpace = (bounds.width - leftInset - rightInset).floored(toScale: traitCollection.currentDisplayScale)
            
            var labelPreferredSize = label.sizeThatFits(CGSize(width: horizontalSpace, height: .greatestFiniteMagnitude))
            labelPreferredSize.width = min(labelPreferredSize.width, horizontalSpace)
            
            label.frame = CGRect(origin: CGPoint(x: leftInset + (isRTL ? horizontalSpace - labelPreferredSize.width : 0.0), y: bounds.maxY + 8.0),
                                 size: labelPreferredSize)
        }
        
        if let label = validationAccessoryLabel {
            layoutValidationLabel(label)
        }
        if let oldLabel = oldValidationAccessoryLabel {
            layoutValidationLabel(oldLabel)
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
    
    
    open override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        setNeedsLayout()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let newCategory = traitCollection.preferredContentSizeCategory
        var needsLayout = false
        if newCategory != previousTraitCollection?.preferredContentSizeCategory ?? .unspecified {
            contentSizeCategoryDidChange(newCategory)
            needsLayout = true
        }
        if traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            needsLayout = true
        }
        if needsLayout {
            setNeedsLayout()
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        if isSelected && selectionStyle == .underline && validationColor == nil {
            updateSeparatorColor()
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
        
        updateSeparatorColor()
        
        let wantsUnderline = isSelected && selectionStyle == .underline
        if (separatorView.bounds.height >~ 1.0) != wantsUnderline {
            setNeedsLayout()
        }
    }
    
    private func updateSeparatorColor() {
        let wantsUnderline = isSelected && selectionStyle == .underline
        let validationColor: UIColor? = requiresValidation ? self.validationColor : nil
        let finalColor = validationColor ?? (wantsUnderline ? separatorView.tintColor : separatorColor)
        separatorView.backgroundColor = finalColor
    }
    
    @objc private func touchTriggerDidActivate(_ trigger: TouchRecognizer) {
        // Don't fire the trigger if it's within a view in the action view.
        if let hitTestedView = actionView?.hitTest(trigger.location(in: actionView), with: nil),
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

