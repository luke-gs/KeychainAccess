//
//  CollectionViewFormCell.swift
//  FormKit
//
//  Created by Rod Brown on 4/05/2016.
//  Copyright © 2016 Rod Brown. All rights reserved.
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
open class CollectionViewFormCell: UICollectionViewCell {
    
    
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
            scrollViewInset = CollectionViewFormCellActionView.singleButtonWidth * CGFloat(editActionCount)
        }
    }

    
    /// The editing display state of the cell.
    ///
    /// This property manages the display of edit actions. Setting this value calls `setShowingEditActions: animated:`
    /// without an animation.
    open fileprivate(set) dynamic var isShowingEditActions: Bool {
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
                scrollView.contentInset.right = 0.0
                removeActionView()
            } else {
                _scrolling = scrollView.contentOffset != .zero
            }
        } else {
            applyTouchTrigger()
            let offset = CGPoint(x: CGFloat(actionView?.buttons?.count ?? 0) * CollectionViewFormCellActionView.singleButtonWidth, y: 0.0)
            
            scrollView.setContentOffset(offset, animated: animated)
            
            if animated {
                _scrolling = scrollView.contentOffset != .zero
            }
        }
    }
    
    
    open let contentModeLayoutGuide: UILayoutGuide = UILayoutGuide()
    
    
    /// CollectionViewFormCell overrides this UIView flag to adjust its content positioning.
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
            contentModeLayoutConstraint?.isActive = false
            contentModeLayoutConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: attribute, relatedBy: .equal, toItem: contentView.layoutMarginsGuide, attribute: attribute)
            contentModeLayoutConstraint.isActive = true
        }
    }
    
    fileprivate var contentModeLayoutConstraint: NSLayoutConstraint!
    
    
    // MARK: - Private properties
    
    fileprivate let internalContentView = UIView(frame: .zero)
    fileprivate var scrollView: CollectionViewFormCellScrollView!
    fileprivate var actionView: CollectionViewFormCellActionView?
    fileprivate var _isShowingEditActions: Bool = false
    fileprivate var _deceleratingToOpen: Bool = false
    fileprivate var _scrolling: Bool    = false
    fileprivate var touchTrigger: TouchRecognizer?
    
    fileprivate var scrollViewInset: CGFloat = 0.0 {
        didSet {
            let dragging = scrollView.isDragging
            if dragging || scrollView.contentOffset.x.isZero == false {
                scrollView.contentInset.right = scrollViewInset
            }
            if dragging == false {
                setShowingEditActions(isShowingEditActions, animated: window != nil)
            }
        }
    }
    
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        removeTouchTrigger()
    }
    
}


// MARK: - Scroll handling
/// Scroll handling
extension CollectionViewFormCell: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        if contentOffset.x < 0 {
            contentOffset.x = 0.0
            scrollView.contentOffset = contentOffset
        } else if contentOffset.x > scrollView.bounds.size.width {
            contentOffset.x = scrollView.bounds.size.width
            scrollView.contentOffset = contentOffset
        }
        update(for: contentOffset)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let xVelocity = velocity.x
        
        var movingIntoEditing = false
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
                scrollView.contentInset.right = 0.0
                removeActionView()
            }
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.superview(of: UICollectionView.self)?.endEditing(true)
        scrollView.contentInset.right = scrollViewInset
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
            scrollView.contentInset.right = 0.0
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
            scrollView.contentInset.right = 0.0
            removeActionView()
        }
    }
    
    fileprivate func update(for scrollContentOffset: CGPoint) {
        let size = scrollView.bounds.size
        
        if actionView == nil && scrollContentOffset.x.isZero == false {
            superview(of: UICollectionView.self)?.endEditing(true)
            actionView = CollectionViewFormCellActionView(cell: self)
            actionView!.updateForButtonsItems((editActions?.map { let color = $0.color ?? .gray;
                return ($0.title, color)}))
            scrollView.addSubview(actionView!)
        }
        actionView?.frame = CGRect(x: size.width, y: 0.0, width: scrollContentOffset.x, height: size.height)
    }
}

extension CollectionViewFormCell: DefaultReusable {
}



// MARK: - Overrides
/// Overrides
extension CollectionViewFormCell {
    
    open class override func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == #keyPath(CollectionViewFormCell.isShowingEditActions) {
            return false
        } else {
            return super.automaticallyNotifiesObservers(forKey: key)
        }
    }
    
    open override var contentView: UIView {
        return internalContentView
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        applyStandardFonts()
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
            newLayoutMargins = formAttribute.layoutMargins
        } else {
            newLayoutMargins = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
        
        if layoutMargins != newLayoutMargins {
            layoutMargins = newLayoutMargins
            setNeedsLayout()
        }
        if internalContentView.layoutMargins != newLayoutMargins {
            internalContentView.layoutMargins = newLayoutMargins
            setNeedsLayout()
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitTestedView = super.hitTest(point, with: event) else { return nil }
        
        if _scrolling { return internalContentView }
        
        
        // If we're dragging, don't receive additional touches.
        if scrollView.isDragging {
            return scrollView
        }
        
        // If the scroll view is decelerating, only accept touches on the action view, and only when decelerating to open.
        // If not decelerating to open or not touching the action view, pass the touch to the content view.
        // This will ensure we won't get selection activity, but we can still catch scroll behaviour.
        if scrollView.isDecelerating {
            if _deceleratingToOpen,
                let actionView = self.actionView
                , hitTestedView.isDescendant(of: actionView) {
                    return hitTestedView
            } else {
                return internalContentView
            }
        }
        
        // The hit test on the cell will find the content view, the scroll view or a subview. The content view
        // and the scroll view will block selection. If we're not currently showing edit actions, return ourself instead,
        // to allow selection to occur.
        if isShowingEditActions == false && (hitTestedView == internalContentView || hitTestedView == scrollView) {
            return self
        }
        
        return hitTestedView
    }
    
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}

internal extension CollectionViewFormCell {
    
    internal func applyStandardFonts() {}
    
}



// MARK: - Private
/// Private methods
private extension CollectionViewFormCell {
    
    func commonInit() {
        super.contentMode = .center
        
        let trueContentView        = super.contentView
        let contentModeLayoutGuide = self.contentModeLayoutGuide
        
        scrollView = CollectionViewFormCellScrollView(cell: self)
        scrollView.delegate      = self
        scrollView.frame         = trueContentView.bounds
        scrollView.autoresizingMask  = [.flexibleWidth, .flexibleHeight]
        scrollView.isScrollEnabled = false
        trueContentView.addSubview(scrollView)
        addGestureRecognizer(scrollView.panGestureRecognizer)
        
        internalContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        internalContentView.frame = scrollView.bounds
        internalContentView.clipsToBounds = true
        scrollView.addSubview(internalContentView)
        
        internalContentView.addLayoutGuide(contentModeLayoutGuide)
        
        contentModeLayoutConstraint = NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .centerY, relatedBy: .equal, toItem: internalContentView, attribute: .centerYWithinMargins)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: internalContentView, attribute: .leadingMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: internalContentView, attribute: .trailingMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: internalContentView, attribute: .topMargin),
            NSLayoutConstraint(item: contentModeLayoutGuide, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: internalContentView, attribute: .bottomMargin, priority: 500),
            contentModeLayoutConstraint
        ])
        
        applyStandardFonts()
    }
    
    @objc func touchTriggerDidActivate(_ trigger: TouchRecognizer) {
        // Don't fire the trigger if it's within the action view.
        if let actionView = self.actionView , actionView.bounds.contains(trigger.location(in: actionView)) {
            return
        }
        
        self.setShowingEditActions(false, animated: true)
    }
    
    func applyTouchTrigger() {
        if touchTrigger != nil { return }
        if let collectionView = superview(of: UICollectionView.self) {
            let touchTrigger = TouchRecognizer(target: self, action: #selector(touchTriggerDidActivate(_:)))
            touchTrigger.delegate = self
            collectionView.addGestureRecognizer(touchTrigger)
            self.touchTrigger = touchTrigger
        }
    }
    
    func removeTouchTrigger() {
        if let touchTrigger = self.touchTrigger {
            touchTrigger.view?.removeGestureRecognizer(touchTrigger)
            self.touchTrigger = nil
        }
    }
    
    func removeActionView() {
        if let actionView = self.actionView {
            actionView.removeFromSuperview()
            self.actionView = nil
        }
    }
}

extension CollectionViewFormCell: UIGestureRecognizerDelegate {
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
    
    init(cell: CollectionViewFormCell) {
        self.cell = cell
        
        super.init(frame: .zero)
        
        panGestureRecognizer.delegate = self
        decelerationRate = (UIScrollViewDecelerationRateFast + UIScrollViewDecelerationRateNormal) / 2.0
        delaysContentTouches = false
        alwaysBounceVertical = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isDirectionalLockEnabled = true
    }
    
    /// CollectionViewFormCellScrollView does not support NSCoding.
    required init?(coder aDecoder: NSCoder) {
        return nil
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
        if contentOffset.x.isZero && firstResponderSubview != nil {
            return false
        }
        return true
    }
}


/// A private view which manages the editing buttons for the cell.
private class CollectionViewFormCellActionView: UIView {
    
    static let singleButtonWidth: CGFloat = 80.0
    
    unowned let cell: CollectionViewFormCell
    
    var buttons: [UIButton]?
    
    init(cell: CollectionViewFormCell) {
        self.cell = cell
        super.init(frame: .zero)
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        UIView.performWithoutAnimation {
            let bounds = self.bounds
            let buttonWidth = CollectionViewFormCellActionView.singleButtonWidth
            var startX: CGFloat = bounds.width - buttonWidth
            
            self.buttons?.forEach { (button: UIButton) in
                button.frame = CGRect(x: startX, y: 0.0, width: buttonWidth, height: bounds.height)
                button.layoutIfNeeded()
                startX -= buttonWidth
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
        if let editActions = cell.editActions {
            let editCount = editActions.count
            let tag = button.tag
            if editCount <= tag { return }
            
            if let indexPath = superview(of: UICollectionView.self)?.indexPath(for: cell) {
                editActions[tag].action?(cell, indexPath)
            }
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


extension UIView {
    
    /// A convenience to find the subview which is currently the first responder, if any.
    var firstResponderSubview: UIView? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let firstResponderSubview = subview.firstResponderSubview {
                return firstResponderSubview
            }
        }
        return nil
    }
}
