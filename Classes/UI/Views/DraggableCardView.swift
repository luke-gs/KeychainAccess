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
    func didHideView()
    func didRevealView()
}

open class DraggableCardView: UIView {

    open weak var delegate: DraggableCardViewDelegate?

    open private(set) var gripBar = UIView(frame: .zero)

    open private(set) var scrollView: UIScrollView = UIScrollView(frame: .zero)

    open private(set) var contentView = UIView(frame: .zero)

    open private(set) var panGesture: UIPanGestureRecognizer!

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

    private func createSubviews() {
        gripBar.backgroundColor = .disabledGray
        gripBar.layer.cornerRadius = 3
        addSubview(gripBar)

        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func createConstraints() {

        gripBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gripBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            gripBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            gripBar.heightAnchor.constraint(equalToConstant: 6),
            gripBar.widthAnchor.constraint(equalToConstant: 48),

            scrollView.topAnchor.constraint(equalTo: gripBar.bottomAnchor),
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


    /// Hides the view by moving it down and informs the delegate
    open func hide() {
        UIView.animate(withDuration: 0.25) {
            self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        }

        // Cancel recogniser
        panGesture.isEnabled = false
        panGesture.isEnabled = true

        delegate?.didHideView()
    }

    /// Uses the pan gesture to move the card on screen
    @objc open func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(panGesture) else {
            return
        }

        switch gestureRecognizer.state {

        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)

        case .changed:
            let translation = gestureRecognizer.translation(in: self).y

            let elasticThreshold: CGFloat = 120
            let dismissThreshold: CGFloat = 240

            let translationFactor: CGFloat = 1/2

            // Only do something if translation is from top (i.e >= 0)
            if translation >= 0 {
                // Add some friction
                // from: https://github.com/HarshilShah/DeckTransition
                let translationForModal: CGFloat = {
                    if translation >= elasticThreshold {
                        let frictionLength = translation - elasticThreshold
                        let frictionTranslation = 30 * atan(frictionLength/120) + frictionLength/10
                        return frictionTranslation + (elasticThreshold * translationFactor)
                    } else {
                        return translation * translationFactor
                    }
                }()

                // Set the transform to transform with friction
                self.transform = CGAffineTransform(translationX: 0, y: translationForModal)

                // Dissmiss if we are past the threshold
                if translation >= dismissThreshold {
                    hide()
                }
            }

        case .ended:
            UIView.animate(withDuration: 0.25) {
                self.transform = .identity
            }

        default: break
        }
    }
}

