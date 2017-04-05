//
//  CollectionViewFormCellActionView.swift
//  Pods
//
//  Created by Rod Brown on 2/4/17.
//
//

import UIKit
import QuartzCore

private let interButtonSpacing: CGFloat = 8.0

internal class CollectionViewFormCellActionView: UIScrollView, UIScrollViewDelegate {
    
    // MARK: - Internal properties
    
    weak var actionDelegate: CollectionViewFormCellActionDelegate?
    
    var actions: [CollectionViewFormEditAction] = [] {
        didSet {
            if actions == oldValue { return }
            
            setNeedsButtonReload()
            
            let hasActions = actions.isEmpty == false
            let isShowingActions = self.isShowingActions
            
            if hasActions && isScrollEnabled == false {
                isScrollEnabled = true
            } else if hasActions == false && isShowingActions == false {
                isScrollEnabled = false
            }
            
            if isDragging == false && isShowingActions && hasActions == false {
                setShowingActions(false, animated: true)
            }
        }
    }
    
    var isShowingActions: Bool {
        get { return contentOffset.x !=~ 0.0 || isDragging }
        set { setShowingActions(newValue, animated: false) }
    }
    
    func setShowingActions(_ showingActions: Bool, animated: Bool) {
        if (isShowingActions == false && showingActions == false) || (showingActions && actions.isEmpty) {
            return
        }
        
        if isShowingActions == false {
            actionDelegate?.actionViewWillShowActions(self)
        }
        
        if showingActions && buttons == nil {
            setNeedsButtonReload()
        }
        layoutIfNeeded()
        
        let contentOffset: CGPoint
        if showingActions {
            contentOffset = CGPoint(x: isRightToLeft ? contentInset.left : -contentInset.right, y: 0.0)
        } else {
            contentOffset = .zero
        }
        
        // Reset the pan gesture, cancelling any touches in the current pan and stopping the drag.
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = isScrollEnabled
        
        if contentOffset == self.contentOffset {
            return
        }
        
        setContentOffset(contentOffset, animated: animated)
        if animated == false {
            scrollViewDidEndMovement(self)
        }
    }
    
    var wantsGradientMask: Bool = true {
        didSet {
            if wantsGradientMask == oldValue { return }
            
            layer.mask = wantsGradientMask ? maskLayer : nil
        }
    }
    
    
    // MARK: - Private properties
    
    private var isRightToLeft: Bool = false {
        didSet {
            if isRightToLeft == oldValue { return }
            setNeedsButtonLayout()
            setNeedsMaskGradientUpdate()
        }
    }
    
    private var buttons: [UIButton]?
    
    private var maskLayer: CAGradientLayer? {
        didSet {
            if maskLayer == oldValue || wantsGradientMask == false { return }
            self.layer.mask = maskLayer
        }
    }
    
    private var needsButtonReload: Bool = false
    
    private var needsButtonLayout: Bool = false
    
    private var needsMaskGradientUpdate: Bool = false
    
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        super.delegate = self
        isHidden = true
        decelerationRate = UIScrollViewDecelerationRateFast        
        
        alwaysBounceHorizontal         = true
        isDirectionalLockEnabled       = true
        delaysContentTouches           = false
        alwaysBounceVertical           = false
        showsVerticalScrollIndicator   = false
        showsHorizontalScrollIndicator = false
        
        if #available(iOS 10, *) {
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        } else {
            isRightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        }
    }
    
    
    // MARK: - Property Overrides
    
    override var frame: CGRect {
        didSet {
            let size = frame.size
            if size != oldValue.size {
                contentSize = size
                setNeedsButtonLayout()
                
                if frame.width != oldValue.width {
                    setNeedsMaskGradientUpdate()
                }
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            let size = bounds.size
            if size != oldValue.size {
                contentSize = size
                setNeedsButtonLayout()
                
                if bounds.width != oldValue.width {
                    setNeedsMaskGradientUpdate()
                }
            }
        }
    }
    
    override var layoutMargins: UIEdgeInsets {
        didSet {
            if layoutMargins != oldValue && buttons?.count ?? 0 > 0 {
                setNeedsButtonLayout()
                setNeedsMaskGradientUpdate()
            }
        }
    }
    
    override var delegate: UIScrollViewDelegate? {
        get { return self }
        set { }
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: Avoid allowing scrolling the action buttons *further* offscreen
        
        let bounds = self.bounds
        
        // Avoid scrolling action buttons further than offscreen
        var contentOffset = self.contentOffset
        if isRightToLeft {
            if contentOffset.x > 0 {
                contentOffset.x = 0.0
                self.contentOffset = contentOffset
            } else if contentOffset.x < -bounds.width {
                contentOffset.x = -bounds.width
                self.contentOffset = contentOffset
            }
        } else {
            if contentOffset.x < 0 {
                contentOffset.x = 0.0
                self.contentOffset = contentOffset
            } else if contentOffset.x > bounds.width {
                contentOffset.x = bounds.width
                self.contentOffset = contentOffset
            }
        }
        
        // Hide if necessary.
        
        let shouldBeHidden = contentOffset == .zero
        if shouldBeHidden != isHidden {
            isHidden = shouldBeHidden
        }
        
        
        // Manage Masks
        
        if maskLayer == nil && isShowingActions {
            let gradientMask = CAGradientLayer()
            gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
            maskLayer = gradientMask
            
            needsMaskGradientUpdate = true
        }
        
        if needsMaskGradientUpdate {
            if let gradient = maskLayer {
                let startPointX: CGFloat
                let endPointX: CGFloat
                
                if isRightToLeft {
                    let layoutPercentage: CGFloat
                    if bounds.width > 0.001 {
                        layoutPercentage = layoutMargins.right / bounds.width
                    } else {
                        layoutPercentage = 0.0
                    }
                    startPointX = layoutPercentage
                    endPointX   = 0.0
                } else {
                    let layoutPercentage: CGFloat
                    if bounds.width > 0.001 {
                        layoutPercentage = (bounds.width - layoutMargins.right) / bounds.width
                    } else {
                        layoutPercentage = 0.0
                    }
                    startPointX = layoutPercentage
                    endPointX   = 1.0
                }
                
                gradient.startPoint = CGPoint(x: startPointX, y: 0.5)
                gradient.endPoint   = CGPoint(x: endPointX,   y: 0.5)
            }
            
            needsMaskGradientUpdate = false
        }
        
        if let maskLayer = self.maskLayer {
            // Move the mask layer to the current bounds. Note: we do this within a CATransaction to avoid implicit animations.
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            maskLayer.frame = bounds
            CATransaction.commit()
        }
        
        
        // Manage buttons
        
        if needsButtonReload || (isShowingActions && (buttons?.count ?? 0 != actions.count)) {
            // reload items if needed
            
            buttons?.forEach { $0.removeFromSuperview() }
            var reusableButtons = buttons
            
            buttons = actions.enumerated().map {
                let button: UIButton
                if reusableButtons?.isEmpty ?? true == false,
                    let dequeuedButton = reusableButtons?.remove(at: 0) {
                    button = dequeuedButton
                } else {
                    button = UIButton(type: .custom)
                    button.addTarget(self, action: #selector(buttonTapped(_:)), for: .primaryActionTriggered)
                    button.setTitleColor(.white, for: .normal)
                    button.setTitleColor(.gray,  for: .highlighted)
                    button.contentHorizontalAlignment = .center
                    if let titleLabel = button.titleLabel {
                        titleLabel.adjustsFontSizeToFitWidth = true
                        titleLabel.allowsDefaultTighteningForTruncation = true
                        titleLabel.minimumScaleFactor = 0.7
                        titleLabel.font = .systemFont(ofSize: 11.0)
                    }
                    button.layer.cornerRadius = 16.0
                    self.addSubview(button)
                }
                button.backgroundColor = $0.element.color ?? .gray
                button.setTitle($0.element.title, for: .normal)
                button.tag = $0.offset
                return button
            }
            
            // Remove old and unused buttons
            reusableButtons?.forEach { $0.removeFromSuperview() }
            
            needsButtonReload = false
            needsButtonLayout = true
        }
        
        if needsButtonLayout {
            
            if let buttons = self.buttons, buttons.isEmpty == false {
                let contentRect = bounds.insetBy(layoutMargins)
                
                // The y position and height of the buttonFrame should be consistent. Adjust x and width as appropriate.
                var buttonFrame = CGRect(x: bounds.width, y: contentRect.midY - 16.0, width: 0.0, height: 32.0)
                
                let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 11.0)]
                let scale = traitCollection.currentDisplayScale
                
                let reversedButtons = buttons.reversed()
                let reversedButtonWidths = actions.reversed().map { $0.title.size(attributes: attributes).width.ceiled(toScale: scale) }
                
                if isRightToLeft {
                    buttonFrame.origin.x = 0.0
                    for (index, button) in reversedButtons.enumerated() {
                        let buttonWidth = max(reversedButtonWidths[index], 6.0) + 26.0
                        buttonFrame.size.width =  buttonWidth
                        buttonFrame.origin.x  -= buttonWidth
                        button.frame           = buttonFrame
                        buttonFrame.origin.x  -= interButtonSpacing
                    }
                    contentInset.left = (buttonFrame.origin.x + interButtonSpacing) * -1.0 + layoutMargins.left
                } else {
                    for (index, button) in reversedButtons.enumerated() {
                        buttonFrame.size.width = max(reversedButtonWidths[index], 6.0) + 26.0
                        button.frame = buttonFrame
                        buttonFrame.origin.x = buttonFrame.maxX + interButtonSpacing
                    }
                    contentInset.right = buttonFrame.minX - bounds.width - interButtonSpacing + layoutMargins.right
                }
                
            } else {
                contentInset.left  = 0.0
                contentInset.right = 0.0
            }
            
            needsButtonLayout = false
        }
    }
    
    
    // MARK: - Reload & Adjustment flags
    
    private func setNeedsButtonReload() {
        if buttons != nil {
            needsButtonReload = true
            setNeedsLayout()
        }
    }
    
    private func setNeedsButtonLayout() {
        if buttons?.count ?? 0 > 0 {
            needsButtonLayout = true
            setNeedsLayout()
        }
    }
    
    private func setNeedsMaskGradientUpdate() {
        needsMaskGradientUpdate = true
        setNeedsLayout()
    }
    
    
    // MARK: - Trait changes
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 10, *) {
            // Trait changes only trigger RLT changes in iOS 10+
            isRightToLeft = effectiveUserInterfaceLayoutDirection == .rightToLeft
        }
        
        if traitCollection.currentDisplayScale != previousTraitCollection?.currentDisplayScale {
            setNeedsLayout()
        }
    }

    
    // MARK: - Gesture handling.
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            // We're only going to interfere with the defaults if it's our pan gesture,
            // and even then, only return `false` in cases where we know we shouldn't be recognizing.
            // Otherwise, let the standard scroll behaviours stand.
            
            if let cells = superview(of: UICollectionView.self)?.visibleCells {
                let isDraggingActionView = { (cell: UICollectionViewCell) -> Bool in
                    return (cell as? CollectionViewFormCell)?.actionView.isDragging ?? false
                }
                
                if cells.contains(where: isDraggingActionView) {
                    return false
                }
            }
            
            if actionDelegate?.actionViewShouldBeginDragging(self) ?? true == false {
                // Don't recognize appearance scrolls if the cell has a first responder subview (an active text field, etc)
                return false
            }
        }
        
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    
    // MARK: - Delegate methods
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // If we began dragging when we were offset, we don't need to make any adjustments
        // as we're in "showing" mode already
        if contentOffset.x !=~ 0.0 { return }
        
        actionDelegate?.actionViewWillShowActions(self)
    }
    
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let xVelocity = velocity.x
        
        if isRightToLeft {
            if xVelocity > 0.25 {
                targetContentOffset.pointee.x = 0.0
            } else if xVelocity < -1.0 {
                targetContentOffset.pointee.x = -scrollView.contentInset.left
            } else {
                let contentInset = scrollView.contentInset.left
                if targetContentOffset.pointee.x < (contentInset / -2.0) {
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
            } else {
                let contentInset = scrollView.contentInset.right
                if targetContentOffset.pointee.x > (contentInset / 2.0) {
                    targetContentOffset.pointee.x = contentInset
                } else {
                    targetContentOffset.pointee.x = 0.0
                }
            }
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            scrollViewDidEndMovement(scrollView)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndMovement(scrollView)
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndMovement(scrollView)
    }
    
    private func scrollViewDidEndMovement(_ scrollView: UIScrollView) {
        // If we didn't come to rest in the "closed" position, there's nothing further to do.
        if contentOffset.x !=~ 0.0 { return }
        
        actionDelegate?.actionViewDidHideActions(self)
        
        var contentInset = self.contentInset
        contentInset.left  = 0.0
        contentInset.right = 0.0
        self.contentInset = contentInset
        
        let buttons = self.buttons
        self.buttons = nil
        
        buttons?.forEach { $0.removeFromSuperview() }
        maskLayer = nil
        
        needsButtonReload = false
        needsButtonLayout = false
        needsMaskGradientUpdate = false
        
        if actions.isEmpty {
            isScrollEnabled = false
        }
    }
    
    
    // MARK: - Button action
    
    @objc private func buttonTapped(_ button: UIButton) {
        let buttonIndex = button.tag
        if buttonIndex < actions.count && buttonIndex >= 0 {
            actionDelegate?.actionView(self, didSelectActionAt: buttonIndex)
        }
    }
    
}


// MARK: -
// MARK: - CollectionViewFormCellActionDelegate

protocol CollectionViewFormCellActionDelegate: class {
    
    func actionViewShouldBeginDragging(_ actionView: CollectionViewFormCellActionView) -> Bool
    
    func actionViewWillShowActions(_ actionView: CollectionViewFormCellActionView)
    
    func actionViewDidHideActions(_ actionView: CollectionViewFormCellActionView)
    
    func actionView(_ actionView: CollectionViewFormCellActionView, didSelectActionAt index: Int)
    
}

