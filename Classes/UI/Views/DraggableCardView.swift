//
//  DraggableCardView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 27/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit

public protocol DraggableCardViewDelegate: class {
    func didDragView(offset: CGFloat)
    func didHideView()
    func didShowView()
}

/// View for showing content that can be hidden/shown by dragging header bar
open class DraggableCardView: UIView {

    open weak var delegate: DraggableCardViewDelegate?

    open private(set) var dragBar = UIView(frame: .zero)

    open private(set) var scrollView: UIScrollView = UIScrollView(frame: .zero)

    open private(set) var contentView = UIView(frame: .zero)

    open private(set) var panGesture: UIPanGestureRecognizer!

    open var isShowing: Bool = true

    private struct Constants {
        static let elasticThreshold: CGFloat = 50
        static let translationFactor: CGFloat = 0.5
        static let hideThresholdDragging: CGFloat = 100
        static let hideThresholdReleased: CGFloat = 50
    }

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 8

        createSubviews()
        createConstraints()

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        addGestureRecognizer(panGesture)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open func createSubviews() {
        dragBar.backgroundColor = .disabledGray
        dragBar.layer.cornerRadius = 3
        addSubview(dragBar)

        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    open func createConstraints() {
        dragBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

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


    open func convertTranslation(_ translation: CGFloat) -> CGFloat {
        // Add some friction
        // from: https://github.com/HarshilShah/DeckTransition
        if translation >= Constants.elasticThreshold {
            let frictionLength = translation - Constants.elasticThreshold
            let frictionTranslation = 30 * atan(frictionLength / 120) + frictionLength / 10
            return frictionTranslation + (Constants.elasticThreshold * Constants.translationFactor)
        } else {
            return translation * Constants.translationFactor
        }
    }

    open func updateShowing(_ isShowing: Bool) {
        // Cancel recogniser
        panGesture.isEnabled = false
        panGesture.isEnabled = true

        self.isShowing = isShowing
        if isShowing {
            delegate?.didShowView()
        } else {
            delegate?.didHideView()
        }
    }

    /// Uses the pan gesture to move the card on screen
    @objc open func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(panGesture) else {
            return
        }

        let translation = convertTranslation(gestureRecognizer.translation(in: self).y)
        switch gestureRecognizer.state {

        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)

        case .changed:
            // Only do something if translation is related to changing state
            if (isShowing && translation >= 0) || (!isShowing && translation <= 0) {

                // Update delegate
                delegate?.didDragView(offset: translation)

                // Show/hide if past the dragging threshold
                if abs(translation) > Constants.hideThresholdDragging {
                    updateShowing(!isShowing)
                }
            }

        case .ended:
            // Only do something if translation is related to changing state
            if (isShowing && translation >= 0) || (!isShowing && translation <= 0) {
                // Show/hide if past the released threshold
                if abs(translation) > Constants.hideThresholdReleased {
                    updateShowing(!isShowing)
                    return
                }
            }
            updateShowing(isShowing)

        default: break
        }
    }
}

