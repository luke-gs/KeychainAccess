//
//  TasksListHeaderCompactViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 12/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View controller for the header above tasks list showing source name and options to filter and add new tasks,
/// when split view is in compact size mode
///
/// Note: this header shown/hidden by the tasks split view controller
open class TasksListHeaderCompactViewController: UIViewController {

    private struct Constants {
        static let headerHeight: CGFloat = 56
        static let buttonPadding: CGFloat = 20
        static let titleMargin: CGFloat = 10
    }

    public let viewModel: TasksListHeaderViewModel

    /// Title label
    public let titleLabel = UILabel(frame: .zero)

    /// Bar button item stackview
    public let buttonStackView = UIStackView(frame: .zero)

    /// Button for changing the source
    public let sourceButton = UIButton(type: .custom)

    /// Divider line for source button and stack view
    public let sourceDivider = UIView(frame: .zero)

    /// The currently displayed source view controller, if any
    private var sourceViewController: CompactSidebarSourceViewController? = nil

    /// The current sources available to display
    public var sourceItems: [SourceItem] = [] {
        didSet {
            sourceViewController?.items = sourceItems

            if let selectedSourceIndex = selectedSourceIndex,
                selectedSourceIndex >= sourceItems.count {
                self.selectedSourceIndex = nil
            } else {
                let defaultIndex = sourceItems.count > 0 ? 0 : nil
                self.selectedSourceIndex = selectedSourceIndex ?? defaultIndex
            }
        }
    }

    /// The selected source index
    public var selectedSourceIndex: Int? = nil {
        didSet {
            sourceViewController?.selectedIndex = selectedSourceIndex

            if let selectedSourceIndex = selectedSourceIndex {
                precondition(selectedSourceIndex < sourceItems.count)
                sourceButton.setTitle(sourceItems[selectedSourceIndex].shortTitle, for: .normal)

                // Update color to match source status
                switch sourceItems[selectedSourceIndex].state {
                case .loaded(_, let color):
                    sourceButton.backgroundColor = color
                default:
                    sourceButton.backgroundColor = .lightGray
                }
            } else {
                sourceButton.setTitle(nil, for: .normal)
            }

            // Update title to match source
            titleLabel.text = viewModel.titleText()
        }
    }

    // MARK: - Initializers

    public init(viewModel: TasksListHeaderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        createSubviews()
        createConstraints()
        updateFromViewModel()
    }

    public func createSubviews() {
        let theme = ThemeManager.shared.theme(for: .dark)
        view.backgroundColor = theme.color(forKey: .background)!
        view.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = viewModel.titleText()
        titleLabel.textColor = theme.color(forKey: .primaryText)!
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        buttonStackView.alignment = .center
        buttonStackView.spacing = 16
        view.addSubview(buttonStackView)

        sourceButton.translatesAutoresizingMaskIntoConstraints = false
        sourceButton.backgroundColor = .lightGray
        sourceButton.setTitleColor(UIColor.black, for: .normal)
        sourceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        sourceButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        sourceButton.layer.cornerRadius = 3
        sourceButton.addTarget(self, action: #selector(didTapSourceButton(_:)), for: .touchUpInside)
        view.addSubview(sourceButton)

        sourceDivider.translatesAutoresizingMaskIntoConstraints = false
        sourceDivider.backgroundColor = UIColor.gray
        view.addSubview(sourceDivider)

        // Shrink label, not buttons if not enough space
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
    }
    
    public func createConstraints() {
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: Constants.headerHeight),
            sourceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonPadding),
            sourceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            sourceDivider.leadingAnchor.constraint(equalTo: sourceButton.trailingAnchor, constant: Constants.buttonPadding),
            sourceDivider.topAnchor.constraint(equalTo: view.topAnchor),
            sourceDivider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sourceDivider.widthAnchor.constraint(equalToConstant: 1),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: sourceDivider.trailingAnchor, constant: Constants.titleMargin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor, constant: -Constants.titleMargin),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).withPriority(.almostRequired),

            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonPadding),
            buttonStackView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }

    // MARK: - Data model

    public func updateFromViewModel() {
        for barButtonItem in viewModel.barButtonItems {
            let button = UIButton(type: .custom)
            button.setImage(barButtonItem.image, for: .normal)
            button.addTarget(barButtonItem.target, action: barButtonItem.action!, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }

        sourceItems = viewModel.sourceItems
        if !sourceItems.isEmpty {
            selectedSourceIndex = 0
        }
    }
    
    @objc private func didTapSourceButton(_ item: UIBarButtonItem) {
        guard let selectedSourceIndex = selectedSourceIndex else { return }
        sourceViewController = CompactSidebarSourceViewController(items: sourceItems, selectedIndex: selectedSourceIndex)
        sourceViewController?.delegate = self

        // Use form sheet style presentation, even on phone
        let navVC = CompactFormSheetNavigationController(rootViewController: sourceViewController!, parent: navigationController!)
        present(navVC, animated: true, completion: nil)
    }

}

extension TasksListHeaderCompactViewController: CompactSidebarSourceViewControllerDelegate {
    public func sourceViewControllerWillClose(_ viewController: CompactSidebarSourceViewController) {
    }

    public func sourceViewController(_ viewController: CompactSidebarSourceViewController, didSelectItemAt index: Int) {
        viewModel.selectedSourceIndex = index
    }

    public func sourceViewController(_ viewController: CompactSidebarSourceViewController, didRequestToLoadItemAt index: Int) {
    }
}

/// Add support for presenting modal dialogs from our non standard bar button items
extension TasksListHeaderCompactViewController: TasksListHeaderViewModelDelegate {

    public func sourceItemsChanged(_ sourceItems: [SourceItem]) {
        self.sourceItems = sourceItems
    }

    public func selectedSourceItemChanged(_ selectedSourceIndex: Int) {
        self.selectedSourceIndex = selectedSourceIndex
    }

    public func presentPopover(_ viewController: UIViewController, barButtonIndex: Int, animated: Bool) {
        if let buttonView = buttonStackView.arrangedSubviews[ifExists: barButtonIndex] {
            presentPopover(viewController, sourceView: buttonView, sourceRect: buttonView.bounds, animated: animated)
        }
    }
}
