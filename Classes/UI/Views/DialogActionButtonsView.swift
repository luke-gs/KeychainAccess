//
//  DialogActionButtonsView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// View for showing actions buttons at the bottom of a form modal dialog
open class DialogActionButtonsView: UIView {

    /// Layout sizing constants
    public struct LayoutConstants {
        public static let verticalPadding: CGFloat = 24
        public static let horizontalPadding: CGFloat = 24
        public static let centerOffset: CGFloat = 3
    }

    /// The action buttons to be displayed
    public let actions: [DialogAction]
    open private(set) var buttons: [DialogActionView] = []

    // MARK: - Subviews

    /// Stack view for action buttons
    open var buttonStackView: UIStackView!

    /// Footer dividing line
    open var footerDivider: UIView!

    /// The button layout style
    open var layoutStyle: DialogActionLayoutStyle

    // MARK: - Setup

    public init(actions: [DialogAction], layoutStyle: DialogActionLayoutStyle = .adaptive) {
        self.layoutStyle = layoutStyle
        self.actions = actions
        super.init(frame: .zero)

        createSubviews()
        createConstraints()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    /// Creates and styles views
    open func createSubviews() {
        buttonStackView = UIStackView(frame: .zero)
        buttonStackView.axis = layoutStyle == .vertical ? .vertical : .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStackView)

        // Create buttons
        for (index, action) in actions.enumerated() {
            let actionView = DialogActionView(action: action)
            // If multiple items and this is not the last, give it a side divider
            if index != actions.count - 1 && actions.count > 1 {
                actionView.showsSideDivider = true
            }
            buttonStackView.addArrangedSubview(actionView)
            buttons.append(actionView)
        }
    }

    /// Activates view constraints
    open func createConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaOrFallbackBottomAnchor),
        ])
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if layoutStyle == .adaptive {
            if traitCollection.horizontalSizeClass == .compact && actions.count > 2 {
                buttonStackView.axis = .vertical
            } else {
                buttonStackView.axis = .horizontal
            }
        }
    }
}

/// The Dialog Action Layout Style
///
/// - vertical: buttons are laid out vertically
/// - horizontal: buttons are laid out horizontally
/// - adaptive: buttons are laid out depending on trait collections
public enum DialogActionLayoutStyle {
    case vertical
    case horizontal
    case adaptive
}
