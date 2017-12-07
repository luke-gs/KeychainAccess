//
//  ManageCallsignStatusViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 17/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// View controller for managing the current callsign status
open class ManageCallsignStatusViewController: UIViewController, PopoverViewController, ManageCallsignStatusViewModelDelegate {

    open let viewModel: ManageCallsignStatusViewModel

    /// Scroll view for content view
    open var scrollView: UIScrollView!

    /// Content view for all content above buttons
    open var contentView: UIView!

    /// Stack view for action buttons
    open var buttonStackView: UIStackView!

    /// The button separator views
    open var buttonSeparatorViews: [UIView]!

    /// Form for displaying the current incident (or nothing)
    open var incidentFormVC: CallsignIncidentFormViewController!

    /// Collection of callsign statuses
    open var callsignStatusVC: CallsignStatusViewController!

    /// Height constraint for current incident form
    open var incidentFormHeight: NSLayoutConstraint!

    /// Support being transparent when in popover/form sheet
    open var wantsTransparentBackground: Bool = false {
        didSet {
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
            incidentFormVC.wantsTransparentBackground = wantsTransparentBackground
            callsignStatusVC.wantsTransparentBackground = wantsTransparentBackground
        }
    }

    /// Return the current theme
    private var theme: Theme {
        return ThemeManager.shared.theme(for: .current)
    }
    
    // MARK: - Initializers

    public init(viewModel: ManageCallsignStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        createSubviews()
        createConstraints()

        // Observe theme changes for custom collection view
        NotificationCenter.default.addObserver(self, selector: #selector(interfaceStyleDidChange), name: .interfaceStyleDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - View lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())

        // Set initial background color (this may change in wantsTransparentBackground)
        view.backgroundColor = theme.color(forKey: .background)!
        setupNavigationBarButtons()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
    }

    /// We need to override viewDidLayoutSubviews as well as willTransition due to behaviour of popover controller
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update the title view based on current traits
        setTitleView(title: viewModel.navTitle(), subtitle: viewModel.navSubtitle())
        setupNavigationBarButtons()

        incidentFormHeight.constant = viewModel.shouldShowIncident ? incidentFormVC.calculatedContentHeight() : 0
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            // Update the item size and title view based on new traits
            self.setTitleView(title: self.viewModel.navTitle(), subtitle: self.viewModel.navSubtitle())
            self.setupNavigationBarButtons()
        }, completion: nil)
    }

    /// Adds or removes bar button items for the curernt presented state
    open func setupNavigationBarButtons() {
        // Create done button
        if presentingViewController != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    open func createSubviews() {
        scrollView = UIScrollView(frame: .zero)
        view.addSubview(scrollView)

        contentView = UIView(frame: .zero)
        scrollView.addSubview(contentView)

        incidentFormVC = CallsignIncidentFormViewController(listViewModel: viewModel.incidentListViewModel,
                                                            taskViewModel: viewModel.incidentTaskViewModel)
        incidentFormVC.view.backgroundColor = UIColor.clear
        addChildViewController(incidentFormVC, toView: contentView)

        callsignStatusVC = viewModel.callsignViewModel.createViewController()
        addChildViewController(callsignStatusVC, toView: contentView)

        buttonStackView = UIStackView(frame: .zero)
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 0
        view.addSubview(buttonStackView)

        let tintColor = theme.color(forKey: .tint)!

        buttonSeparatorViews = []
        for (index, buttonText) in viewModel.actionButtons.enumerated() {
            let separatorView = UIView(frame: .zero)
            separatorView.backgroundColor = theme.color(forKey: .separator)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            buttonSeparatorViews.append(separatorView)
            buttonStackView.addArrangedSubview(separatorView)

            let button = UIButton(type: .custom)
            let inset = 20 as CGFloat
            button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            button.setTitle(buttonText, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)
            button.tag = index
            buttonStackView.addArrangedSubview(button)
        }
    }

    open func createConstraints() {
        let incidentFormView = incidentFormVC.view!
        incidentFormView.translatesAutoresizingMaskIntoConstraints = false

        let callsignStatusView = callsignStatusVC.view!
        callsignStatusView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        buttonStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        incidentFormView.setContentCompressionResistancePriority(.required, for: .vertical)

        incidentFormHeight = incidentFormView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            incidentFormView.topAnchor.constraint(equalTo: contentView.topAnchor),
            incidentFormView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            incidentFormView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            incidentFormHeight,

            callsignStatusView.topAnchor.constraint(equalTo: incidentFormView.bottomAnchor),
            callsignStatusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            callsignStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            callsignStatusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func didTapDoneButton(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapActionButton(_ button: UIButton) {
        viewModel.didTapActionButtonAtIndex(button.tag)
    }
    
    // MARK: - Theme

    @objc private func interfaceStyleDidChange() {
        apply(ThemeManager.shared.theme(for: .current))
    }

    open func apply(_ theme: Theme) {
        view.backgroundColor = wantsTransparentBackground ? .clear : theme.color(forKey: .background)

        // Theme button separators
        for separatorView in buttonSeparatorViews {
            separatorView.backgroundColor = theme.color(forKey: .separator)
        }
    }
}
