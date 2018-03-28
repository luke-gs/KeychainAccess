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

    /// Request the nearest card size state for the given translation
    func nearestStateForTranslation(_ translation: CGFloat) -> DraggableCardView.CardState

    /// Notify the delegate of card movement
    func didDragCardView(translation: CGFloat)

    /// Notify the delegate of a change in card state
    func didUpdateCardView()
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

    /// The current display state of the card
    open var currentState: CardState = .normal

    /// Layout constants
    private struct Constants {
        static let translationFactor: CGFloat = 0.75
        static let elasticThreshold: CGFloat = 1200
    }

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)

        createSubviews()
        createConstraints()

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open func createSubviews() {
        // Use rounded corners on self
        let theme = ThemeManager.shared.theme(for: .current)
        self.clipsToBounds = true
        self.backgroundColor = theme.color(forKey: .background)
        self.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Too bad...
        }

        // Add scroll view first (so under bar)
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add drag bar in container
        dragContainer.backgroundColor = self.backgroundColor
        addSubview(dragContainer)

        dragBar.backgroundColor = .disabledGray
        dragBar.layer.cornerRadius = 3
        dragContainer.addSubview(dragBar)
    }

    open func createConstraints() {
        dragBar.translatesAutoresizingMaskIntoConstraints = false
        dragContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Layout drag bar then scroll view containing content view
        NSLayoutConstraint.activate([
            dragContainer.topAnchor.constraint(equalTo: topAnchor),
            dragContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            dragContainer.trailingAnchor.constraint(equalTo: trailingAnchor),

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

    // MARK: - State

    /// Convert the raw translation into card movement
    open func movementForTranslation(_ translation: CGFloat) -> CGFloat {
        // Add some friction, see https://github.com/HarshilShah/DeckTransition
        if translation >= Constants.elasticThreshold {
            let frictionLength = translation - Constants.elasticThreshold
            let frictionTranslation = 30 * atan(frictionLength / 120) + frictionLength / 10
            return frictionTranslation + (Constants.elasticThreshold * Constants.translationFactor)
        } else {
            return translation * Constants.translationFactor
        }
    }

    /// Update state and notify delegate
    open func updateCardState(_ currentState: CardState) {
        // Cancel recogniser
        panGesture.isEnabled = false
        panGesture.isEnabled = true

        self.currentState = currentState
        delegate?.didUpdateCardView()
    }

    /// Return whether a drag is allowed given current state and translation
    open func dragAllowed(translation: CGFloat) -> Bool {
        return (currentState == .minimised && translation <= 0) ||
                (currentState == .maximised && translation >= 0) ||
                currentState == .normal
    }

    /// Uses the pan gesture to move the card on screen
    @objc open func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(panGesture) else {
            return
        }

        let translation = gestureRecognizer.translation(in: self).y
        switch gestureRecognizer.state {

        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)

        case .changed:
            // Only handle gesture if dragging a valid direction
            if dragAllowed(translation: translation) {

                // Update delegate
                delegate?.didDragCardView(translation: movementForTranslation(translation))
            }

        case .ended:
            // Only handle gesture if dragging a valid direction
            if dragAllowed(translation: translation) {

                // Change state if our position has moved closer to a new state
                currentState = delegate?.nearestStateForTranslation(movementForTranslation(translation)) ?? currentState
            }
            updateCardState(currentState)

        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DraggableCardView: UIGestureRecognizerDelegate {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            // Don't trigger gesture if maximised and dragging up, or dragging down when not scrolled to top
            // Let it go to scroll view instead
            let translation = panGesture.translation(in: self).y
            if (currentState == .maximised && (translation < 0 || scrollView.contentOffset.y > 0)) {
                return false
            }
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Make sure our pan recognizer overrides default scroll gesture
        if gestureRecognizer == panGesture {
            return true
        }
        return false
    }
}
