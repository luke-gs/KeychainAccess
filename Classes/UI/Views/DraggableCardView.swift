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
    func didDragCardView(translation: CGFloat)
    func didUpdateCardView()
}

/// View for showing scrollable content that can be minimised or restored using pan gestures
/// on the content view or drag bar
open class DraggableCardView: UIView {

    /// Delegate for observing changes
    open weak var delegate: DraggableCardViewDelegate?

    /// The visual indication of draggable bar
    open private(set) var dragBar = UIView(frame: .zero)

    /// The scroll view for content
    open private(set) var scrollView: UIScrollView = UIScrollView(frame: .zero)

    /// The content view used by caller
    open private(set) var contentView = UIView(frame: .zero)

    /// The pan gesture for moving card
    open private(set) var panGesture: UIPanGestureRecognizer!

    /// Whether the card is currently being shown full size
    open var isShowing: Bool = true

    /// Layout constants
    private struct Constants {
        static let translationFactor: CGFloat = 0.5
        static let elasticThreshold: CGFloat = 120
        static let hideThreshold: CGFloat = 240
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

        // Add drag bar
        dragBar.backgroundColor = .disabledGray
        dragBar.layer.cornerRadius = 3
        addSubview(dragBar)

        // Add scroll view
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    open func createConstraints() {
        dragBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Layout drag bar then scroll view containing content view
        NSLayoutConstraint.activate([
            dragBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dragBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            dragBar.heightAnchor.constraint(equalToConstant: 6),
            dragBar.widthAnchor.constraint(equalToConstant: 48),

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
    open func updateIsShowing(_ isShowing: Bool) {
        // Cancel recogniser
        panGesture.isEnabled = false
        panGesture.isEnabled = true

        self.isShowing = isShowing
        delegate?.didUpdateCardView()
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
            // Only do something if translation is related to changing state
            if (isShowing && translation >= 0) || (!isShowing && translation <= 0) {

                // Update delegate
                delegate?.didDragCardView(translation: movementForTranslation(translation))

                // Show/hide if past the hide threshold
                if abs(translation) > Constants.hideThreshold {
                    updateIsShowing(!isShowing)
                }
            }

        case .ended:
            // Only do something if translation is related to changing state
            if (isShowing && translation >= 0) || (!isShowing && translation <= 0) {
                // Show/hide if past the elastic threshold
                if abs(translation) > Constants.elasticThreshold {
                    updateIsShowing(!isShowing)
                    return
                }
            }
            updateIsShowing(isShowing)

        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DraggableCardView: UIGestureRecognizerDelegate {

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            // Only trigger gesture if dragging down while at top of scroll view, or dragging up when hidden
            let translation = panGesture.translation(in: self).y
            if (isShowing && scrollView.contentOffset.y <= 0 && translation >= 0) || (!isShowing && translation <= 0) {
                return true
            } else {
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
