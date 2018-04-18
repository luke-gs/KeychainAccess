//
//  DialogActionButtonsView.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 7/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

open class DialogAction {

    /// The title to use when displaying the action
    open let title: String

    /// Completion handler upon selecting the action
    open let handler: ((DialogAction) -> Swift.Void)

    public init(title: String, handler: @escaping ((DialogAction) -> Swift.Void)) {
        self.title = title
        self.handler = handler
    }

    /// Called when the action has been selected
    public func didSelect() {
        handler(self)
    }
}

/// View for showing actions buttons at the bottom of a form modal dialog
open class DialogActionButtonsView: UIView {

    /// Layout sizing constants
    public struct LayoutConstants {
        public static let defaultHeight: CGFloat = 64
        public static let verticalPadding: CGFloat = 24
        public static let horizontalPadding: CGFloat = 24
        public static let centerOffset: CGFloat = 3
    }

    /// The action buttons to be displayed
    open let actions: [DialogAction]
    open private(set) var buttons: [UIButton] = []

    // MARK: - Subviews

    /// Stack view for action buttons
    open var buttonStackView: UIStackView!

    /// Footer dividing line
    open var footerDivider: UIView!

    // MARK: - Setup

    public init(actions: [DialogAction]) {
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
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 0
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStackView)

        // Create buttons
        for (index, action) in actions.enumerated() {
            let button = createButton(title: action.title)
            button.tag = index
            buttonStackView.addArrangedSubview(button)
            buttons.append(button)
        }

        // Add footer view, above stackview
        footerDivider = UIView()
        footerDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        footerDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(footerDivider)
    }

    /// Activates view constraints
    open func createConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: LayoutConstants.defaultHeight).withPriority(.defaultHigh),

            footerDivider.topAnchor.constraint(equalTo: topAnchor),
            footerDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerDivider.heightAnchor.constraint(equalToConstant: 1),

            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: safeAreaOrFallbackBottomAnchor),
        ])
    }

    open func createButton(title: String) -> UIButton {
        let theme = ThemeManager.shared.theme(for: .current)
        let tintColor = theme.color(forKey: .tint)!

        let button = UIButton()
        button.contentEdgeInsets = UIEdgeInsets(top: LayoutConstants.verticalPadding,
                                                left: LayoutConstants.horizontalPadding,
                                                bottom: LayoutConstants.verticalPadding - LayoutConstants.centerOffset,
                                                right: LayoutConstants.horizontalPadding)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(tintColor, for: .normal)
        button.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc open func didSelectButton(button: UIButton) {
        let action = actions[ifExists: button.tag]
        action?.didSelect()
    }

}

