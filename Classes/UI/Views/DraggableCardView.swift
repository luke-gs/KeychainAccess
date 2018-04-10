//
//  DraggableCardView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 27/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

/// Delegate for card state changes
public protocol DraggableCardViewDelegate: class {

    /// Ask the delegate for the size to use for different states
    func heightForCardViewInState(_ state: DraggableCardView.CardState) -> CGFloat

    /// Notify the delegate of card movement
    func didDragCardView(translation: CGFloat)

    /// Notify the delegate that a drag has finished
    func didFinishDragCardView()
}

/// View for showing scrollable content that can be minimised or restored using pan gestures
/// on the content view or drag bar
open class DraggableCardView: UIView {

    /// Enum for the current card state
    public enum CardState {
        case normal
        case minimised
        case maximised
    }

    /// Delegate for observing changes
    open weak var delegate: DraggableCardViewDelegate?

    /// The visual indication of draggable bar
    open private(set) var dragBar = UIView(frame: .zero)

    /// The container for the drag bar so scrolled content doesn't touch it
    open private(set) var dragContainer = UIView(frame: .zero)

    /// The scroll view for content
    open private(set) var scrollView: UIScrollView = UIScrollView(frame: .zero)

    /// The content view used by caller
    open private(set) var contentView = UIView(frame: .zero)

    /// The pan gesture for moving card
    open private(set) var panGesture: UIPanGestureRecognizer!

    /// The tap gesture for restoring card
    open private(set) var tapGesture: UITapGestureRecognizer!

    /// The current display state of the card
    open var currentState: CardState = .normal {
        didSet {
            // Allow content scrolling only if maximised
            scrollView.isScrollEnabled = (currentState == .maximised)

            // Allow user interaction of any kind kind only if not minimised
            scrollView.isUserInteractionEnabled = (currentState != .minimised)
        }
    }

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)

        createSubviews()
        createConstraints()

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapGesture.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        // Improve performance of shadow
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }

    open func createSubviews() {
        // Set shadow on base view that is not clipped with corner radius
        backgroundColor = UIColor.clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4.0

        // Add scroll view first (so under bar)
        scrollView.isScrollEnabled = false
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add drag bar container with rounded edges
        addSubview(dragContainer)

        if #available(iOS 11.0, *) {
            dragContainer.layer.cornerRadius = 16
            dragContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // No corners for you...
        }

        // Add drag bar in container
        dragBar.backgroundColor = .disabledGray
        dragBar.layer.cornerRadius = 3
        dragContainer.addSubview(dragBar)

        // Apply current theme
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func createConstraints() {
        dragBar.translatesAutoresizingMaskIntoConstraints = false
        dragContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Layout drag bar then scroll view containing content view
        NSLayoutConstraint.activate([
            // Outset drag container 1 pixel, due to rendering issue with rounded edges
            dragContainer.topAnchor.constraint(equalTo: topAnchor),
            dragContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            dragContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),

            dragBar.topAnchor.constraint(equalTo: dragContainer.topAnchor, constant: 8),
            dragBar.centerXAnchor.constraint(equalTo: dragContainer.centerXAnchor),
            dragBar.heightAnchor.constraint(equalToConstant: 6),
            dragBar.widthAnchor.constraint(equalToConstant: 48),
            dragBar.bottomAnchor.constraint(equalTo: dragContainer.bottomAnchor, constant: -8),

            scrollView.topAnchor.constraint(equalTo: dragBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func apply(_ theme: Theme) {
        scrollView.backgroundColor = theme.color(forKey: .background)
        dragContainer.backgroundColor = theme.color(forKey: .background)
    }


    // MARK: - Dragging

    /// Return whether a drag is allowed given current state and translation
    open func dragAllowed(translation: CGFloat) -> Bool {
        return (currentState == .minimised && translation <= 0) ||
                (currentState == .maximised && translation >= 0) ||
                currentState == .normal
    }

    /// Calculate nearest card state based on current state and release velocity
    open func nearestStateWithVelocity(_ velocity: CGFloat) -> CardState {
        guard let delegate = delegate else { return .normal }

        // Get heights from delegate
        let normalCardHeight = delegate.heightForCardViewInState(.normal)
        let minimisedCardHeight = delegate.heightForCardViewInState(.minimised)
        let maximisedCardHeight = delegate.heightForCardViewInState(.maximised)

        // Once going past a threshold in the right direction, move to next state
        let threshold = 30 as CGFloat
        let cardHeight = bounds.height

        if velocity <= 0 {
            // Card is moving up
            if cardHeight > normalCardHeight + threshold {
                return .maximised
            } else  if cardHeight > minimisedCardHeight + threshold {
                return .normal
            } else {
                return .minimised
            }

        } else {
            // Card is moving down
            if cardHeight < normalCardHeight - threshold {
                return .minimised
            } else  if cardHeight < maximisedCardHeight - threshold {
                return .normal
            } else {
                return .maximised
            }
        }
    }

    /// Uses the pan gesture to move the card on screen
    @objc open func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(panGesture) else { return }

        let translation = gestureRecognizer.translation(in: self).y
        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)

        case .changed:
            // Only handle gesture if dragging a valid direction
            if dragAllowed(translation: translation) {

                // Update delegate to update position
                delegate?.didDragCardView(translation: translation)
            }

        case .ended:
            // Only handle gesture if dragging a valid direction
            if dragAllowed(translation: translation) {

                // Change state if our position has moved closer to a new state
                let velocity = gestureRecognizer.velocity(in: self).y
                currentState = nearestStateWithVelocity(velocity)
            }
            // Always update delegate, even if state hasn't changed to re-position card
            delegate?.didFinishDragCardView()

        case .cancelled:
            // Always update delegate, even if state hasn't changed to re-position card
            delegate?.didFinishDragCardView()

        default: break
        }
    }

    /// Uses the tap gesture to restore the card when minimised
    @objc open func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.isEqual(tapGesture) else { return }

        if gestureRecognizer.state == .ended && currentState == .minimised {
            currentState = .normal
            delegate?.didFinishDragCardView()
        }
    }

}

// MARK: - UIGestureRecognizerDelegate

extension DraggableCardView: UIGestureRecognizerDelegate {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            // Don't trigger our gesture if (let it go to scroll view instead):
            // - maximised and dragging up (so we can scroll content up)
            // - maximised and dragging down if not at top (so we can scroll content down)
            let translation = panGesture.translation(in: self).y
            let velocity = panGesture.velocity(in: self)
            if (currentState == .maximised && (translation < 0 || scrollView.contentOffset.y > 0)) {
                return false
            }
            // Don't trigger gesture if panning horizontally (eg in MPOLSplitViewController page controller)
            if fabs(velocity.x) > fabs(velocity.y) * 2 {
                return false
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Make sure our pan recognizer overrides other pan gestures
        if gestureRecognizer == panGesture && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return true
        }
        return false
    }
}
