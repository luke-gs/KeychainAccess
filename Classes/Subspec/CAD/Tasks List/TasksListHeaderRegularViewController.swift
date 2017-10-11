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
open class TasksListHeaderRegularViewController: UIViewController {

    private struct Constants {
        static let topMargin: CGFloat = 32
        static let leadingMargin: CGFloat = 24
        static let trailingMargin: CGFloat = 18
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

        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false

        let theme = ThemeManager.shared.theme(for: .dark)

        titleLabel.text = viewModel.titleText()
        titleLabel.textColor = theme.color(forKey: .primaryText)!
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.bold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.alignment = .center
        view.addSubview(buttonStackView)

        for barButtonItem in viewModel.barButtonItems {
            let button = UIButton(type: .custom)
            button.setImage(barButtonItem.image, for: .normal)
            button.addTarget(barButtonItem.target, action: barButtonItem.action!, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.leadingMargin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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

        // Do any additional setup after loading the view.
    }

}

extension TasksListHeaderRegularViewController: TasksListHeaderViewModelDelegate {
    public func presentPopover(_ viewController: UIViewController, barButton: UIBarButtonItem?, animated: Bool) {
        let nav = PopoverNavigationController(rootViewController: viewController)
        nav.popoverPresentationController?.barButtonItem = barButton
        nav.modalPresentationStyle = .popover
        present(nav, animated: true, completion: nil)
    }
}
