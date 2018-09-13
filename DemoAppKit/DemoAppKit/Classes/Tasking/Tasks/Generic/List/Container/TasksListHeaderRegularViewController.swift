//
//  TasksListHeaderRegularViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for the header above tasks list showing source name and options to filter and add new tasks,
/// when split view is in regular size mode
///
/// Note: this header is shown/hidden by the tasks container view controller
open class TasksListHeaderRegularViewController: UIViewController {

    private struct Constants {
        static let topMargin: CGFloat = 32
        static let leadingMargin: CGFloat = 24
        static let trailingMargin: CGFloat = 18
        static let internalMargin: CGFloat = 10
    }

    public let viewModel: TasksListHeaderViewModel

    /// Title label
    public let titleLabel = UILabel(frame: .zero)

    /// Bar button item stackview
    public let buttonStackView = UIStackView(frame: .zero)

    // MARK: - Initializers

    public init(viewModel: TasksListHeaderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let theme = ThemeManager.shared.theme(for: .dark)

        view.backgroundColor = theme.color(forKey: .background)!
        view.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = viewModel.titleText()
        titleLabel.textColor = theme.color(forKey: .primaryText)!
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.bold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.alignment = .center
        buttonStackView.spacing = 16
        view.addSubview(buttonStackView)

        // Shrink label, not buttons if not enough space
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leadingMargin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor, constant: -Constants.internalMargin),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).withPriority(.almostRequired),

            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.trailingMargin),
            buttonStackView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        reloadButtons()
    }

    public func reloadButtons() {
        buttonStackView.removeArrangedSubviewsFromViewHierarchy()
        for barButtonItem in viewModel.barButtonItems {
            let button = UIButton(type: .custom)
            button.setImage(barButtonItem.image, for: .normal)
            button.addTarget(barButtonItem.target, action: barButtonItem.action!, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
    }
}

/// Add support for presenting modal dialogs from our non standard bar button items
extension TasksListHeaderRegularViewController: TasksListHeaderViewModelDelegate {

    public func sourceItemsChanged(_ sourceItems: [SourceItem]) {
        titleLabel.text = viewModel.titleText()
    }

    public func selectedSourceItemChanged(_ selectedSourceIndex: Int) {
        titleLabel.text = viewModel.titleText()
    }

    public func barButtonItemsChanged() {
        reloadButtons()
    }

    public func presentPopover(_ viewController: UIViewController, barButtonIndex: Int, animated: Bool) {
        if let buttonView = buttonStackView.arrangedSubviews[ifExists: barButtonIndex] {
            presentPopover(viewController, sourceView: buttonView, sourceRect: buttonView.bounds, animated: animated)
        }
    }
}
